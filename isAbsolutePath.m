function isAbsolutePath = isAbsolutePath(path)
    % Check if the path starts with a path separator character or a drive letter
    isAbsolutePath = (path(1) == '/' || path(1) == '\' || (isletter(path(1)) && path(2) == ':'));
end
