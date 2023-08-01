#!/usr/bin/r

fs::path
obj_package <- function (..., ext = "") 
{
    args <- list(...)
    assert_recyclable(args)
    path_tidy(.Call(fs_path_, lapply(args, function(x) enc2utf8(as.character(x))), 
        ext))
}

