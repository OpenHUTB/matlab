


classdef ReadOnlyCheckService<handle

    properties(Access=protected)
        m_checkServices=[];
    end

    methods(Access=public)
        function obj=ReadOnlyCheckService()
            obj.m_checkServices=containers.Map();
        end

        function[isReadOnly,msg]=checkObject(this,objectUri)
            isReadOnly=false;
            msg='';
            try
                checkers=values(this.m_checkServices);
                len=numel(checkers);
                for i=1:len
                    checker=checkers{i};

                    try
                        if checker.dependsOnPropertyName()
                            continue;
                        end

                        isReadOnly=checker.check(objectUri,'');

                        if isReadOnly
                            msg=checker.getMessage(objectUri,'');
                            break;
                        end
                    catch ex
                    end
                end
            catch ex
            end
        end

        function[isReadOnly,msg]=checkObjectProperty(this,objectUri,propertyname)
            isReadOnly=false;
            msg='';
            try
                checkers=values(this.m_checkServices);
                len=numel(checkers);
                for i=1:len
                    checker=checkers{i};

                    if~checker.dependsOnPropertyName()
                        continue;
                    end

                    isReadOnly=checker.check(objectUri,propertyname);

                    if(isReadOnly)
                        msg=checker.getMessage(objectUri,propertyname);
                        break;
                    end
                end
            catch ex
            end
        end

        function registerChecker(this,checker)

            this.m_checkServices(checker.getName())=checker;
        end

        function unregisterChecker(this,checkerName)

            remove(this.m_checkServices,checkerName);
        end
    end
end
