# The contents of this file are subject to the MonetDB Public License
# Version 1.1 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://monetdb.cwi.nl/Legal/MonetDBLicense-1.1.html
#
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.
#
# The Original Code is the MonetDB Database System.
#
# The Initial Developer of the Original Code is CWI.
# Portions created by CWI are Copyright (C) 1997-July 2008 CWI.
# Copyright August 2008-2011 MonetDB B.V.
# All Rights Reserved.

# Exception classes for the ruby-monetdb driver

class MonetDBQueryError < StandardError
  def initialize(e)
    $stderr.puts e
  end
end

class MonetDBDataError < StandardError
  def initialize(e)
    $stderr.puts e
  end
end

class MonetDBCommandError < StandardError
  def initialize(e)
    $stderr.puts e
  end
end

class MonetDBConnectionError < StandardError
  def initialize(e)
    $stderr.puts e
  end
end


class MonetDBSocketError < StandardError
  def initialize(e)
    $stderr.puts e
  end
end

class MonetDBProtocolError < StandardError
   def initialize(e)
     $stderr.puts e
   end  
end