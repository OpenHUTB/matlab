function retVal=packageHasDataClasses(package,className)










    retVal=true;

    if ismember(package,{'Simulink';'mpt'})

        return;
    end

    hP=meta.package.fromName(package);
    if isempty(hP)
        retVal=false;
        return;
    end


    classList={'Signal';'Parameter'};
    if nargin==2
        assert(ischar(className));
        assert(ismember(className,classList));
        classList={className};
    end



    for idx=1:length(classList)
        thisClassName=classList{idx};
        superClassName=['Simulink.',thisClassName];
        hClass=Simulink.data.findClass(hP,thisClassName);
        if(isempty(hClass)||...
            ~Simulink.data.isDerivedFrom(hClass,superClassName))

            retVal=false;
            return;
        end
    end
end
