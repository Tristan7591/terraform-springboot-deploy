{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/opt/tomcat/logs/catalina.out",
            "log_group_name": "/aws/java/application-logs",
            "log_stream_name": "{instance_id}/catalina-out",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/myapp/app.log",
            "log_group_name": "/aws/java/application-logs",
            "log_stream_name": "{instance_id}/app-log",
            "timezone": "UTC"
          }
        ]
      }
    }
  }
}
