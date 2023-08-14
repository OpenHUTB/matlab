



function ret=flattenCovObjects(covObjects)
    ret=vertcat(covObjects{:}).';
end
