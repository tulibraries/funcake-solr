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

    context "with a non-case character difference" do
      let(:search_term) { "padig:shí-vag97hr" }

      it "does not return the record" do
        expect(records).not_to include(identifier)
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

    context "with a differently capitalized exact identifier" do
      let(:search_term) { "padig:shi-vag97hr" }

      it "returns the record" do
        expect(records).to include(identifier)
      end
    end

    context "with a differently capitalized wildcard identifier" do
      let(:search_term) { 'padig\:shi-*' }

      it "returns the record" do
        expect(records).to include(identifier)
      end
    end
  end
end
