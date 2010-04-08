class DataMapper::Query
  
  def to_hash
    {
      "repository" => self.repository.name,
      "model" => self.model.name,
      "fields" => self.fields.collect { |p| "#{p.model}.#{p.name}" },
      "links" => [], # I need to see an example of this,
      "order" => self.order.collect { |o| "#{o.target.model}.#{o.target.name}.#{o.operator}" },
      "limit" => self.limit,
      "offset" => self.offset,
      "reload" => @reload,
      "unique" => @unique,
      "conditions" => operation_to_hash(self.conditions)
    }
  end
  
  def to_json
    to_hash.to_json
  end
  
  def all
    repository.scope { model.all(self) }
  end
  
  class << self
    
    def from_json(json)
      from_hash(JSON.parse(json))
    end
    
    def from_hash(hash)
      
      respository = (hash["repository"] || :default).to_sym
      model = string_to_model(hash["model"])
      options = {}
      
      # fields
      unless hash["fields"].blank? || !hash["fields"].is_a?(Array)
        options[:fields] = hash["fields"].collect { |f| string_to_property(f) }
      end
      
      # links, again, I don't know enough about, I've never used them
      
      # order
      unless hash["order"].blank? || !hash["order"].is_a?(Array)
        options[:order] = hash["order"].collect { |p| string_to_order(p) }
      end
      
      options[:limit] = hash["limit"] unless hash["limit"].blank?
      options[:offset] = hash["offset"] unless hash["offset"].blank?
      
      unless hash["conditions"].blank?
        options[:conditions] = string_to_conditions(hash["conditions"])
      end
      
      new(repository, model, options)
      
    end#from_hash
    
  private
    def string_to_model(string)
      DataMapper::Model.descendants.find { |m| m.name == string }
    end

    def string_to_property(string)
      strings = string.split(".")

      if model = string_to_model(strings[0])
        model.properties[strings[1]]
      else
        nil
      end
    end

    def string_to_relationship(string)
      strings = string.split(".")

      if model = string_to_model(strings[0])
        model.relationships[strings[1]]
      else
        nil
      end
    end

    def string_to_order(string)
      property = string_to_property(string)
      direction = string.split(".")[2] || :asc
      DataMapper::Query::Direction.new(property, direction.to_sym)
    end

    def string_to_conditions(conditions)
      if DataMapper::Query::Conditions::Operation.slugs.include?(conditions.keys.first.to_sym)
        string_to_operation(conditions)
      elsif DataMapper::Query::Conditions::Comparison.slugs.include?(conditions.keys.first.to_sym)
        string_to_comparison(conditions)
      else
        nil
      end
    end

    def string_to_operation(operation)
      slug = operation.keys.first.to_sym
      operands = operation.values.first.collect { |o| string_to_conditions(o) }
      DataMapper::Query::Conditions::Operation.new(slug, *operands)
    end

    def string_to_comparison(comparison)
      slug = comparison.keys.first.to_sym
      compare = comparison.values.first
      subject = string_to_subject(compare.keys.first)
      value = compare.values.first
      
      if value.is_a?(Hash) && value.keys.length == 1 && value.keys.first == "collection"
        value = DataMapper::Collection.new(DataMapper::Query.from_hash(value.values.first))
      end
      
      DataMapper::Query::Conditions::Comparison.new(slug, subject, value)
    end

    def string_to_subject(subject)
      if property = string_to_property(subject)
        property
      else
        string_to_relationship(subject)
      end
    end
    
  end#class << self
  
private
  def operation_to_hash(operation)
    return {} if operation.slug == :null # just forget null's, they don't exist
    
    {
      operation.slug => operation.operands.collect { |o| operand_to_hash(o) }
    }
  end
  
  def operand_to_hash(operand)
    # TODO: figure out a better way to detect what type of object it is
    
    if operand.respond_to?(:subject) # it's a comparison
      comparison_to_hash(operand)
    elsif operand.respond_to?(:operands) # it's an operation
      operation_to_hash(operand)
    else # it must be some other kind of object
      operand
    end
  end
  
  def comparison_to_hash(comparison)
    value = comparison.value
    value = { "collection" => value.query.to_hash } if value.class == DataMapper::Collection
    
    {
      comparison.slug => {
        subject_to_hash(comparison.subject) => value
      }
    }
  end
  
  def subject_to_hash(subject)
    if subject.respond_to?(:parent_model)
      "#{subject.source_model}.#{subject.name}"
    else
      "#{subject.model}.#{subject.name}"
    end
  end
  
end