function environment=getEnvironment(domain)








    if nargin<1
        domain=learning.simulink.internal.getAcademyDomain();
    end

    pattern='.*-(?<env>\w+).mathworks.com.*';
    names=regexp(domain,pattern,'names');


    if isempty(names)||isequal(names.env,'bash')
        environment='production';
    else
        environment=names.env;
    end
end