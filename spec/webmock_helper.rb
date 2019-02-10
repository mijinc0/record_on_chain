#  License of this file is followed as follows
#
#  MIT License
#
#  Copyright (c) 2017 Yoshiyuki Ieyama
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in all
#  copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#  SOFTWARE.

require 'webmock'
require 'yaml'
require 'json'

FIXTURES_PATH = File.expand_path('../fixtures', __FILE__)

def load_stub_from_json(path)
  file_path = File.join(FIXTURES_PATH, "#{path}.json")
  File.exist?(file_path) ? File.read(file_path) : raise("#{file_path} is not found.")
end

def hash_stub_from_json(path)
  JSON.parse(load_stub_from_json(path), symbolize_names: true)
end

NEM_URL = 'http://127.0.0.1:7890'.freeze
routes  = YAML.load_file(File.join(FIXTURES_PATH, 'webmock_routes.yml'))

WebMock.enable!

routes.each do |path, opts|
  stub_method = (opts['method'] || :get).to_sym
  stub_status = (opts['status'] || 200).to_i
  stub_path   = (opts['stub']   || path).tr('/', '_')
  stub_body   = load_stub_from_json(stub_path)
  stub_params = opts['params']

  webmock = WebMock.stub_request(stub_method, "#{NEM_URL}/#{path}").to_return(
    body:    stub_body,
    status:  stub_status,
    headers: { 'Content-Type' => 'application/json' }
  )

  unless stub_params.nil?
    if stub_method == :post
      webmock.with(
        body: stub_params,
        headers: { 'Content-Type' => 'application/json' }
      )
    else
      webmock.with(
        query: stub_params
      )
    end
  end
end
