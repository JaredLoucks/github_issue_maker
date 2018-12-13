# github_issue_maker
This is a module to be included on a user issue report ActiveRecord model.
The issue model needs the following:
- description column
- git hash column
- screenshot column
- url column
- method to call the current application user's ActiveRecord instance, which should respond to `id` and either `email` or `login`.

You will also need to configure an options hash to pass to github_issue_maker with the following parameters set:
```
github_issue_maker_config_options = {
  instance_details: { description_column: :your_description_column, 
                      git_hash_column:    :your_git_hash_column,
                      screenshot_column:  :your_screenshot_column,
                      url_column:         :your_url_column,
                      user_method:        :your_user_method }, 
  github_details:   { access_token: your_github_access_token,
                      user:         your_github_username,
                      repo:         your_github_repo,
                      labels:       an_array_of_labels_for_your_created_github_issue,
                      issue_title:  a_title_for_your_created_github_issue },
  s3_details:       { bucket: your_s3_images_bucket,
                      region: your_s3_region } 
}

```
Then paste this in the issue model to gain access to the `create_github_issue!` method:
```
require 'github_issue_maker'
include GithubIssueMaker
GithubIssueMaker::GITHUB_ISSUE_MAKER_CONFIG = github_issue_maker_config_options