require 'spec_helper'

describe GithubIssueMaker do
  before do
    GITHUB_ISSUE_MAKER_CONFIG = {
      instance_details: { description_column: :description,
                          git_hash_column:    :git_hash,
                          screenshot_column:  :screenshot,
                          url_column:         :url,
                          user_method:        :user },
      github_details:   { access_token: 'TOKENTOKENTOKEN',
                          user:         'git_guy',
                          repo:         'grepo',
                          labels:       ['end_user_feedback', 'automated_issue'],
                          issue_title:  'End user feedback' },
      s3_details:       { bucket: 'images-yo',
                          region: 'region-yo' }
    }

    @user_issue = Object.new
    @user_issue.extend(GithubIssueMaker)
    @user_issue.stub(:description).and_return('test description')
    @user_issue.stub(:git_hash).and_return('test git hash')
    @user_issue.stub(:screenshot).and_return('test screenshot')
    @user_issue.stub(:url).and_return('test url')

    @user = Object.new
    @user.stub(:try).and_return('test user')
    @user_issue.stub(:user).and_return(@user)

    @s3_dummy_instance = Object.new
    @s3_dummy_instance.stub(:put_object)
    Aws::S3::Client.stub(:new).and_return(@s3_dummy_instance)
    allow_any_instance_of(Github::Client::Issues).to receive(:create).with(user: 'git_guy', repo: 'grepo',
                                                                           title: 'End user feedback', body: 'test body',
                                                                           labels: ['end_user_feedback', 'automated_issue']).
                                                     and_return({html_url: "generated URL for new github issue"})
  end

  describe 'github issue creation' do
    it 'has sections for Description, User, URL, Screenshot, and current git HEAD hash' do
      @user_issue.stub(:github_issue_body).and_return('test body')
      github_issue_url = @user_issue.create_github_issue!

      expect(github_issue_url).to eq("generated URL for new github issue")
    end
  end

  describe 'github issue body' do
    before do
      @user_issue.instance_variable_set(:@instance_details, GITHUB_ISSUE_MAKER_CONFIG[:instance_details])
      @user_issue.instance_variable_set(:@github_details,   GITHUB_ISSUE_MAKER_CONFIG[:github_details])
      @user_issue.instance_variable_set(:@s3_details,       GITHUB_ISSUE_MAKER_CONFIG[:s3_details])
    end

    it 'includes Description, User, URL, Screenshot, and HEAD sections with data passed in from config hash' do
      github_issue_body = @user_issue.github_issue_body('test_screenshot_url')

      expect(github_issue_body).to eq("# Description \n test description\n \n# User \n test user - (test user)\n \n"\
                                      "# URL \n test url\n \n# Screenshot \n "\
                                      "![Issue](https://s3-region-yo.amazonaws.com/images-yo/test_screenshot_url)"\
                                      "\n \n# HEAD \n test git hash")
    end
  end

  describe 'decoded issue screenshot' do
    before do
      @user_issue.instance_variable_set(:@instance_details, GITHUB_ISSUE_MAKER_CONFIG[:instance_details])
    end

    it 'removes base 64 data from image' do
      image = 'test_image'
      decoded_image = Base64.decode64(image)
      encoded_image = "data:image/image_name;base64,#{image}"
      @user_issue.stub(:screenshot).and_return(encoded_image)

      expect(@user_issue.decoded_issue_screenshot).to eq(decoded_image)
    end
  end
end