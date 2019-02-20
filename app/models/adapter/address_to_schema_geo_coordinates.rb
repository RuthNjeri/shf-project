#!/usr/bin/ruby


#--------------------------
#
# @class Adapter::AddressToSchemaGeoCoordinates
#
# @desc Responsibility: (an Adapter) takes an Address and creates a
#   schema.org GeoCoordinates
#     Pattern: Adapter
#       Adaptee: Address
#       Target: schema.org GeoCoordinates https://schema.org/GeoCoordinates
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-02-19
#
# @file company_to_schema_geo_coordinates.rb
#
#--------------------------

module Adapter

  class AddressToSchemaGeoCoordinates < AbstractSchemaOrgAdapter


    def target_class
      SchemaDotOrg::GeoCoordinates
    end


    def set_target_attributes(target)
      target.latitude  = @adaptee.latitude
      target.longitude = @adaptee.longitude
      target
    end

  end

end

