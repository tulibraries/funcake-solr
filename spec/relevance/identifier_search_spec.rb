# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Identifier searches" do
  solr = RSolr.connect(url: ENV["SOLR_URL"])

  let(:response) do
    solr.get(
      "select",
      params: {
        q: search_term,
        qf: query_field,
        defType: "edismax",
        rows: 10
      }
    )
  end

  let(:records) do
    (response.dig("response", "docs") || []).map { |doc| doc.fetch("id")}
  end

  let(:query_field) { "id_search" }

  context "with an exact identifier" do
    let(:identifier) { "padig:SHI-vag97hr" }

    context "with the indexed capitalization" do
      let(:search_term) { identifier }

      it "returns the record" do
        expect(records).to include(identifier)
      end
    end

    context "with different capitalization" do
      let(:search_term) { identifier.downcase }

      it "returns the record" do
        expect(records).to include(identifier)
      end
    end
  end

  context "with a wildcard identifier" do
    let(:identifier) { "padig:SHI-vag97hr" }
    context "with the indexed capitalization" do
      let(:search_term) { 'padig\:SHI-*' }

      it "returns the record" do
        expect(records).to include(identifier)
      end
    end

    context "with different capitalization" do
      let(:search_term) { 'padig\:shi-*' }

      it "returns the record" do
        expect(records).to include(identifier)
      end
    end
  end

  context "with the default query fields" do
    let(:identifier) { "padig:SHI-vag97hr" }
    let(:search_term) { 'padig\:shi-*' }

    let(:response) do
      solr.get(
        "search",
        params: {
          q: search_term,
          defType: "edismax",
          rows: 10
        }
      )
    end

    it "returns the record for a differently capitalized wildcard identifier" do
      expect(records).to include(identifier)
    end
  end
end
