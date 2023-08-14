

function endPoint=getEndPoint()
    import matlab.internal.lang.capability.Capability;
    academyDomain=learning.simulink.internal.getAcademyDomain();



    if Capability.isSupported(Capability.LocalClient)
        endPoint=[academyDomain,'/service/v1/discovery'];
        return;
    end



    slDomain=char(matlab.internal.UrlManager().SIMULINK);
    academySubdomain=learning.simulink.internal.util.CourseUtils().getSubdomain(academyDomain);

    endPoint=[slDomain,'/courses/discovery/',academySubdomain];
end