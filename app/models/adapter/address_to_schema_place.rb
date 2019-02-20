#!/usr/bin/ruby


#--------------------------
#
# @class Adapter::AddressToSchemaPlace
#
# @desc Responsibility: (an Adapter) takes an Address and creates a
#   schema.org Place
#     Pattern: Adapter
#       Adaptee: Address
#       Target: schema.org Place  https://schema.org/Place
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-02-19
#
# @file company_to_schema_org_place.rb
#
#--------------------------

module Adapter

  class AddressToSchemaPlace < AbstractSchemaOrgAdapter


    def target_class
      SchemaDotOrg::Place
    end


    def set_target_attributes(target)
      set_geo_coordinates(set_address(target))
    end


    # =======================================================================


    private


    def set_address(target)
      target.address = Adapter::AddressToSchemaPostalAddress.new(@adaptee).as_target
      target
    end


    def set_geo_coordinates(target)
      target.geo = Adapter::AddressToSchemaGeoCoordinates.new(@adaptee).as_target
      target
    end

  end

end

