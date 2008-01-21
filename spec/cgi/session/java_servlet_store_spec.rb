#--
# **** BEGIN LICENSE BLOCK *****
# Version: CPL 1.0/GPL 2.0/LGPL 2.1
#
# The contents of this file are subject to the Common Public
# License Version 1.0 (the "License"); you may not use this file
# except in compliance with the License. You may obtain a copy of
# the License at http://www.eclipse.org/legal/cpl-v10.html
#
# Software distributed under the License is distributed on an "AS
# IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
# implied. See the License for the specific language governing
# rights and limitations under the License.
#
# Copyright (C) 2007 Sun Microsystems, Inc.
#
# Alternatively, the contents of this file may be used under the terms of
# either of the GNU General Public License Version 2 or later (the "GPL"),
# or the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
# in which case the provisions of the GPL or the LGPL are applicable instead
# of those above. If you wish to allow use of your version of this file only
# under the terms of either the GPL or the LGPL, and not to allow others to
# use your version of this file under the terms of the CPL, indicate your
# decision by deleting the provisions above and replace them with the notice
# and other provisions required by the GPL or the LGPL. If you do not delete
# the provisions above, a recipient may use your version of this file under
# the terms of any one of the CPL, the GPL or the LGPL.
# **** END LICENSE BLOCK ****
#++

require File.dirname(__FILE__) + '/../../spec_helper'

require 'cgi/session/java_servlet_store'

describe CGI::Session::JavaServletStore do
  before :each do
    @session = mock "servlet session"
    @request = mock "servlet request"
    @options = {"java_servlet_request" => @request}
  end

  def session_store
    CGI::Session::JavaServletStore.new(nil, @options)
  end

  it "should raise an error if the servlet request is not present" do
    @options.delete("java_servlet_request")
    lambda { session_store }.should raise_error
  end

  describe "#restore" do
    it "should do nothing if no session established" do
      @request.should_receive(:getSession).and_return nil
      session_store.restore.should == {}
    end
    
    it "should do nothing if the session does not have anything in it" do
      @request.should_receive(:getSession).with(false).and_return @session
      @session.should_receive(:getAttribute).and_return nil
      session_store.restore.should == {}
    end
    
    it "should retrieve the marshalled session from the java session" do
      hash = {"foo" => 1, "bar" => true}
      marshal_data = Marshal.dump hash
      @request.should_receive(:getSession).with(false).and_return @session
      @session.should_receive(:getAttribute).with(
        CGI::Session::JavaServletStore::RAILS_SESSION_KEY).and_return marshal_data.to_java_bytes
      session_store.restore.should == hash
    end
  end
  
  describe "#delete" do
    it "should invalidate the servlet session" do
      @request.should_receive(:getSession).with(false).and_return @session
      @session.should_receive(:invalidate)
      session_store.delete
    end

    it "should do nothing if no session is established" do
      @request.should_receive(:getSession).with(false).and_return nil      
      session_store.delete      
    end
  end
end