require "rails_helper"

RSpec.describe Post, type: :model do
    describe "working with Post" do
        it "can be created" do
            post = create(:post)
            expect(Post.where(id: post.id).exists?).to be true
        end
    end
end