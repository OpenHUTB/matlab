function varargout=rtwattic(method,varargin)








mlock
    persistent USERDATA

    [USERDATA,varargout{1:nargout}]=feval(method,USERDATA,varargin{1:end});




    function userdata=clean(userdata)%#ok
        sourceSubsystemName=coder.internal.SubsystemBuild.getSourceSubsysName;
        BuildDir=rtwattic('getBuildDir');



        isParSSBuild=rtwattic('isParallelSubsystemBuild');
        if isParSSBuild
            model=coder.internal.SubsystemBuild.getNewModelName;
            mdlfname=[model,'.mdl'];
            slxfname=[model,'.slx'];
            if(exist(slxfname,'file')==4)
                builtin('delete',slxfname);
            end
            if(exist(mdlfname,'file')==4)
                builtin('delete',mdlfname);
            end
        end

        hasSIDMap=rtwattic('hasSIDMap');
        SIDMap=rtwattic('getSIDMap');

        clear userdata;
        userdata='';

        if isequal(hasSIDMap,true)





            userdata.hasSIDMap=hasSIDMap;
            userdata.SIDMap=SIDMap;
        end





        if~isempty(sourceSubsystemName)
            userdata.buildDir=BuildDir;
        end




        function userdata=createSIDMap(userdata)
            SIDMap=containers.Map;
            userdata.SIDMap=SIDMap;
            userdata.hasSIDMap=true;




            function userdata=deleteSIDMap(userdata)
                if rtwattic('hasSIDMap')
                    userdata=rmfield(userdata,'SIDMap');
                end
                userdata.hasSIDMap=false;




                function[userdata,hasSIDMap]=hasSIDMap(userdata)
                    if isfield(userdata,'hasSIDMap')
                        hasSIDMap=userdata.hasSIDMap;
                    else
                        hasSIDMap=false;
                    end




                    function userdata=addToSIDMap(userdata,key,value)
                        if rtwattic('hasSIDMap')

                            [~,keyNum]=strtok(key,':');
                            keyNum=keyNum(2:end);

                            [~,valueNum]=strtok(value,':');
                            valueNum=valueNum(2:end);



                            newValueNum=valueNum;
                            while(isKey(userdata.SIDMap,newValueNum))
                                newValueNum=userdata.SIDMap(newValueNum);
                            end
                            userdata.SIDMap(keyNum)=newValueNum;
                        end




                        function[userdata,SIDMap]=getSIDMap(userdata)
                            SIDMap=localGetMethode(userdata,'SIDMap');




                            function userdata=setBuildDir(userdata,buildDirectory)
                                userdata.buildDir=buildDirectory;





                                function[userdata,sourceSubsystemName]=getBuildDir(userdata)
                                    sourceSubsystemName=localGetMethode(userdata,'buildDir');



                                    function userdata=setStartDir(userdata,startDir)
                                        userdata.startDir=startDir;





                                        function[userdata,startDir]=getStartDir(userdata)
                                            startDir=localGetMethode(userdata,'startDir');





                                            function userdata=setTlcTraceInfo(userdata,tlcTraceInfo)
                                                userdata.tlcTraceInfo=tlcTraceInfo;





                                                function[userdata,tlcTraceInfo]=getTlcTraceInfo(userdata)
                                                    tlcTraceInfo=localGetMethode(userdata,'tlcTraceInfo');




                                                    function userdata=setSystemMap(userdata,systemMap)
                                                        if~iscell(systemMap)
                                                            systemMap=strrep(systemMap,newline,'\n');
                                                            systemMap=eval(systemMap);
                                                            for i=1:length(systemMap)
                                                                systemMap{i}=strrep(systemMap{i},'\n',newline);
                                                            end
                                                        end
                                                        userdata.systemMap=systemMap;




                                                        function[userdata,systemMap]=getSystemMap(userdata)
                                                            systemMap=localGetMethode(userdata,'systemMap');
                                                            if isempty(systemMap)
                                                                systemMap={};
                                                            end




                                                            function userdata=setOkayToPushNag(userdata,OkayToPushNag)
                                                                userdata.OkayToPushNag=OkayToPushNag;




                                                                function[userdata,OkayToPushNag]=getOkayToPushNag(userdata)
                                                                    OkayToPushNag=localGetMethode(userdata,'OkayToPushNag');
                                                                    if isempty(OkayToPushNag)
                                                                        OkayToPushNag=false;
                                                                    end



                                                                    function[userdata,value]=getParam(userdata,sys,field)
                                                                        value=get_param(sys,field);
                                                                        if~ischar(value)
                                                                            if isnumeric(value)
                                                                                value=num2str(value);
                                                                            end
                                                                        end




                                                                        function userdata=setParallelSubsystemBuild(userdata,parSubsystemBuild)
                                                                            userdata.parSSBuild=parSubsystemBuild;




                                                                            function[userdata,value]=isParallelSubsystemBuild(userdata)
                                                                                if isfield(userdata,'parSSBuild')
                                                                                    value=userdata.parSSBuild;
                                                                                else
                                                                                    value=false;
                                                                                end



                                                                                function value=localGetMethode(userdata,elementName)
                                                                                    if isfield(userdata,elementName)
                                                                                        value=eval(['userdata.',elementName]);
                                                                                    else
                                                                                        value='';
                                                                                    end




                                                                                    function[StateVar,returnVal]=AtticData(StateVar,varargin)






                                                                                        returnVal=[];
                                                                                        switch(nargin)
                                                                                        case(2)
                                                                                            if isempty(varargin{1})

                                                                                                returnVal=StateVar;
                                                                                            else
                                                                                                if isfield(StateVar,varargin{1})
                                                                                                    returnVal=eval(['StateVar.',varargin{1}]);
                                                                                                end
                                                                                            end
                                                                                        case(3)
                                                                                            if ischar(varargin{1})
                                                                                                eval(['StateVar.',varargin{1},' =  varargin{2};']);
                                                                                            end
                                                                                        end
                                                                                        return;


