#!/usr/bin/env python3

from flask import Flask, send_file
import os
from job import Job


app = Flask(__name__)


@app.route("/")
def index():
    return """
    <h1>Logic Web App</h1>
    <p>This is the Webapp which serves as a the implementation of logic for the my.cc portal as well as the smail script\n
        Multiple paths are available from here:
        <ul>
        <li>logic/pdf/&lt;jobid&gt; will give you a pdf with plots for your a given job id</li>
        <li>logic/plot/&lt;jobid&gt;/&lt;metric&gt; will give you a plot for a given metric for a given job id</li>
        <li>logic/mail/&lt;jobid&gt; will give you the contents of the email sent after completion for a given job id</li>
        </ul>

        Examples
        <ul>
        <li><a href="https://smllr.calculquebec.cloud/logic/pdf/243">A pdf for job 243</a></li>
        <li><a href="https://smllr.calculquebec.cloud/logic/plot/317/jobs_cpu_percent">A plot for job 243's CPU usage</a></li>
        <li><a href="https://smllr.calculquebec.cloud/logic/mail/243">The contents of the email sent after job 243's completion</a></li>
        </ul>
    </p>
    """


@app.route("/mail/<jobid>")
def job_info(jobid):
    job = Job(jobid)
    try:
        job.get_sacct_data()
        job.pull_prometheus()
        job.fill_out_string()
    except Exception as e:
        print(str(e))
        print("This is normal if the job was cancelled, it pulls an empty json")
        pass
    return job.get_out_string()


@app.route("/plot/<jobid>/<metric>")
def job_plot(jobid, metric):
    job = Job(jobid)
    filename = metric + ".png"
    dirname = "/centos/plots/" + str(jobid) + "/"

    if not os.path.isfile(dirname + filename):
        try:
            job.get_sacct_data()
            job.make_plot(metric, filename, dirname)
        except Exception as e:
            print(str(e))
            pass

    try:
        return send_file(dirname + filename, attachment_filename=str(jobid) + filename)
    except Exception as e:
        return str(e)


@app.route("/pie/<jobid>/")
def job_pie(jobid):
    job = Job(jobid)
    metrics = ("jobs_system_time", "jobs_user_time")
    # metrics = ("jobs_cpu_time_core",)
    filename = str(jobid)
    dirname = "/centos/pies/" + str(jobid) + "/"

    for metric in metrics:
        filename += metric + "_"
    filename += ".png"

    if not os.path.isfile(dirname + filename):
        try:
            job.get_sacct_data()
            job.make_pie(metrics, filename, dirname)
        except Exception as e:
            print(str(e))
            pass

    try:
        return send_file(dirname + filename, attachment_filename=filename)
    except Exception as e:
        return str(e)


@app.route("/pdf/<jobid>")
def job_pdf(jobid):
    job = Job(jobid)
    filename = str(jobid) + "_summary.pdf"
    dirname = "/centos/pdf/"
    if not os.path.isfile(dirname + filename):
        try:
            job.get_sacct_data()
            job.make_pdf(jobid, filename, dirname)
        except Exception as e:
            print(str(e))
            pass

    try:
        return send_file(dirname + filename, attachment_filename=filename)
    except Exception as e:
        return str(e)


if __name__ == "__main__":
    app.run(debug=True)
