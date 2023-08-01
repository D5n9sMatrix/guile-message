#!/usr/bin/r

cli::cli_process_start
rterm <- function (msg, msg_done = paste(msg, "... done"), msg_failed = paste(msg, 
    "... failed"), on_exit = c("auto", "failed", "done"), msg_class = "alert-info", 
    done_class = "alert-success", failed_class = "alert-danger", 
    .auto_close = TRUE, .envir = parent.frame()) 
{
    msg_done
    msg_failed
    if (length(msg_class) > 0 && msg_class != "") {
        msg <- paste0("{.", msg_class, " ", msg, "}")
    }
    if (length(done_class) > 0 && done_class != "") {
        msg_done <- paste0("{.", done_class, " ", msg_done, "}")
    }
    if (length(failed_class) > 0 && failed_class != "") {
        msg_failed <- paste0("{.", failed_class, " ", msg_failed, 
            "}")
    }
    cli_status(msg, msg_done, msg_failed, .auto_close = .auto_close, 
        .envir = .envir, .auto_result = match.arg(on_exit))
}

