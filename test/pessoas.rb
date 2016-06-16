# -*- coding: utf-8 -*-
require 'active_record'

# Só execute este programa depois de criar o banco de dados (ruby
# criaSchema.rb)

# Este exemplo só tem dois "parâmetros" (adapter e database). Porém,
# existem outros: (host, username, password), que podem ser usados com
# outros bancos de dados.
ActiveRecord::Base.establish_connection :adapter => "monetdb",
                                        :database => "testdb",
                                        :username => "monetdb",
                                        :password => "monetdb"


class Pessoa < ActiveRecord::Base; 
end

# O bacana aqui é que não foram declarados os atributos da classe
# Pessoa. Para isto, o ActiveRecord vai até o banco de dados, procura
# pelos atributos daquela tabela e automaticamente as "insere" como
# atributos da classe.

# Para demonstrar como acessar estes atributos, vamos a alguns exemplos:

# Formas de inserir informação no banco de dados. 
# Método 1: campo a campo.

p = Pessoa.new()
p.last_name = "Hansen"
p.first_name = "Ola"
p.address    = "Timoteivn 10"
p.city       = "Sandnes"
p.save()

# Método 1: em um único comando.
p = Pessoa.new(:last_name  => "Svendson", 
               :first_name => "Tove",
               :address    => "Borgvn 23",
               :city       => "Sandnes")
p.save()

p = Pessoa.new(:last_name  => "Pettersen", 
               :first_name => "Kari",
               :address    => "Storgt 20",
               :city       => "Stavanger")
p.save()

# Formas de acessar o banco de dados;

# (1) Traz "todo o banco" para uma única variável (Array), e usar os
# iteradores para navegar lá dentro.

pessoas = Pessoa.all;
pessoas.each do |p|
  puts "#{p.id}, #{p.last_name}, #{p.first_name}, #{p.address}, #{p.city}"
end

# (2) Usar o método "find", dando como parâmetro o pk. Verifique a
# classe resultante.

p = Pessoa.find(1)
puts "(Pessoa.find(1)): #{p.id}, #{p.last_name}, #{p.first_name}, #{p.address}, #{p.city}"

# (3) Usar os métodos do tipo "dynamic finders". Estes métodos não
# estão implementados em lugar nenhum. A composição é feita da
# seguinte forma: "<Objeto>.find_by_<nome do atributo>". Muito
# esquisito, mas isto é metaprogramação. Um código será "criado" a
# partir destes parâmetros para fazer a busca no BD. Uma coisa
# importante é que tem dois tipos de finders, o "find" e o
# "find_all". O primeiro retorna um objeto da classe espeficiada. O
# segundo retorna um array de objetos da classe.

pes = Pessoa.where(city: "Stavanger").find_each do |p|
  puts p.class
  puts p.inspect
  puts "(Pessoa.find(...): #{p.id}, #{p.last_name}, #{p.first_name}, #{p.address}, #{p.city}"
end



=begin

1x1 (Pessoa Profissão)
1xn (Pessoa Sapatos)
nxn (Pessoa Casa)

class Profissao <  ActiveRecord::Base; 
  belongs_to :pessoa
end

class Sapato < ActiveRecord::Base; 
  belongs_to :pessoa
end

class Casa  < ActiveRecord::Base; 
   has_and_belongs_to_many :pessoas
end

class Pessoa < ActiveRecord::Base; 
  has_one  :profissao
  has_many :sapatos
  has_and_belongs_to_many :casas

end


=end
