require "rails_helper"

describe "search/embed" do

  it "does not break the regular search form" do
    allow(view).to receive(:params).and_return({action: 'search'})

    render

    expect(rendered).not_to match /target=\"_blank\"/
    expect(rendered).to match /categories/
  end

  it "displays a search form in an embed format" do
    allow(view).to receive(:params).and_return({action: 'embed'})

    render

    expect(rendered).to match /target=\"_blank\"/
    expect(rendered).to match /categories/
  end

  it "changes not sure button to specific group/category if passed in as params[:group]" do

    assign(:category, StudyFinder::Group.create!({ group_name: 'Heart Health' }) )

    allow(view).to receive(:params).and_return({action: 'embed', group: 'Heart%20Health' })

    render

    expect(rendered).to match /search_category/
    expect(rendered).to match /search%5Bcategory%5D=/
  end
end