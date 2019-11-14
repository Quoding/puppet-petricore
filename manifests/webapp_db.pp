class jobs_exporter::webapp {
    exec { 'create_user_and_view':
      command => "puppet:///modules/jobs_expoter/create_user_job_view.sh"
    }
}

