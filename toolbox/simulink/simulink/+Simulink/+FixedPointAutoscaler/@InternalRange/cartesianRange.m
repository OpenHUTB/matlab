




function outRange=cartesianRange(a,b,f)
    vals=[f(a(1),b(1)),f(a(1),b(2)),f(a(2),b(1)),f(a(2),b(2))];
    outRange=[min(vals(:)),max(vals(:))];
end