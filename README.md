# github_issue_maker
This is a module to be included on a user issue report ActiveRecord model.
The issue model needs the following:
- description column
- git hash column
- screenshot column
- url column
- method to call the associated application user

You will need to configure an options hash to pass to github_issue_maker with the following parameters set:
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
                      issue_title:  a_title_for_your_created_github_issue},
  s3_details:       { bucket: your_s3_images_bucket,
                      region: your_s3_region } 
}

```

Put this in the issue model to gain access to `create_github_issue!`:
```
require 'github_issue_maker'
GITHUB_ISSUE_MAKER_CONFIG = github_issue_maker_config_options
