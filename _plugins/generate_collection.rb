module Jekyll

  class DataGeneratedDoc < Document 
    def initialize(site, collection, record, filename, template)
      @site = site
      @path = File.join(site.source, collection.relative_directory, (filename + ".md"))
      @extname = ".md"
      @collection = collection
      data['layout'] = template
      record.each do |key, value|
        data[key] = value
      end
    end
  end

  class DocFromDataGenerator < Generator
    safe true 
    def generate(site)

      loctg = site.config['list_of_collections_to_generate']
      # loctg is an array of hashes
      if loctg # check that it has actually been set in the _config.yml file
      # new_collection_config is a hash, and represents ONE of the new collections we are making
        loctg.each do |new_collection_config|

          # Just getting all of the configurations for each collection to be created
          data_file = new_collection_config['data_file_name']
          coll_label = new_collection_config['collection_name'] || new_collection_config['data_file_name']
          template = new_collection_config['layout'] || new_collection_config['data_file_name']
          attr_for_filename = new_collection_config['record_attr_for_filenames']

          # CREATE THE COLLECTION
          new_collection = Jekyll::Collection.new(site, coll_label)
          new_collection.metadata["output"] = true

          # GET THE ARRAY OF DATA RECORDS
          array_of_records = site.data[data_file]

          # CREATE A DOCUMENT FOR EACH RECORD AND ADD IT TO THE COLLECTION
          array_of_records.each do |record|
            filename = record[attr_for_filename]
            new_doc = DataGeneratedDoc.new(site, new_collection, record, filename, template)
            new_collection.docs << new_doc
          end

          # ADD THE COLLECTION (NOW FULL OF DOCUMENTS) TO THE SITE.COLLECTIONS
          site.collections[new_collection.label] = new_collection
        end
      end
    end
  end
end