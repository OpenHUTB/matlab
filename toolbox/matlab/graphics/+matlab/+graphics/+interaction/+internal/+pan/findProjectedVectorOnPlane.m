function delta=findProjectedVectorOnPlane(orig_ray,curr_ray,normal)



    planept_curr=findIntersectionWithPlane(curr_ray,normal);
    planept_orig=findIntersectionWithPlane(orig_ray,normal);
    delta=planept_orig-planept_curr;


    function q=findIntersectionWithPlane(datapoint,normal)
        u=diff(datapoint);
        p=datapoint(1,:);
        t=dot(-p,normal)/dot(u,normal);
        q=p+t*u;