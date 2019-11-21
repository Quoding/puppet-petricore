class jobs_exporter::db {
    exec { 'create_user_and_view':
      command => "puppet:///modules/jobs_exporter/create_user_job_view.sh"
    }
}

