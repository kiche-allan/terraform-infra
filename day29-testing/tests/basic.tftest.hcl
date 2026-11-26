# Test 1: default values work
run "test_default_environment" {
  command = plan

  assert {
    condition     = var.environment == "test"
    error_message = "Default environment should be 'test'"
  }
}

# Test 2: bucket name contains environment
run "test_bucket_naming" {
  command = apply

  variables {
    environment   = "test"
    bucket_prefix = "day29"
  }

  assert {
    condition     = strcontains(output.bucket_name, "test")
    error_message = "Bucket name must contain the environment name"
  }

  assert {
    condition     = strcontains(output.bucket_name, "day29")
    error_message = "Bucket name must contain the prefix"
  }
}

# Test 3: output environment matches input
run "test_environment_output" {
  command = apply

  variables {
    environment = "staging"
  }

  assert {
    condition     = output.environment == "staging"
    error_message = "Output environment must match input variable"
  }

  assert {
    condition     = strcontains(output.bucket_name, "staging")
    error_message = "Bucket name must reflect the staging environment"
  }
}
