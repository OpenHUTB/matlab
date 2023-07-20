classdef ParentChildComparator<handle






    properties(Access=private)
MyParentName
MyChildName
MyParentCS
MyChildCS
MyComponents
MyErrors
MyDiffParams
MyReporter
MyDistrTargetWithHWNode

MyTargetType
MySelectedComponent
    end


    methods(Access=public)

        function this=ParentChildComparator()
            resetProperties(this);
        end




        function compare(obj,varargin)


            wState=[warning;warning('query','RTW:configSet:migratedToCoderDictionary')];
            warning('off','RTW:configSet:migratedToCoderDictionary');
            wCleanup=onCleanup(@()warning(wState));


            obj.resetProperties();
            obj.parseInputs(varargin{:});


            if~isempty(obj.MySelectedComponent)
                obj.MyComponents=obj.checkComponentCompatibility();
            else
                obj.MyComponents=obj.checkConfigsetCompatibility(obj.MyParentCS,obj.MyChildCS);
            end


            if obj.MyErrors.HadError
                error(obj.MyErrors.ErrMsg);
            end


            obj.compareConfigsets(obj.MyParentCS,obj.MyChildCS,obj.MyComponents);
            if obj.MyErrors.HadError
                error(obj.MyErrors.ErrMsg);
            end
        end





        function report(obj,varargin)
            obj.MyReporter.report(varargin{:});
        end


        function params=getMismatchedParams(obj)
            params=obj.MyDiffParams;
        end


        function name=getParentName(obj)
            name=obj.MyParentName;
        end


        function name=getChildName(obj)
            name=obj.MyChildName;
        end


        function cs=getParentCS(obj)
            cs=obj.MyParentCS;
        end


        function cs=getChildCS(obj)
            cs=obj.MyChildCS;
        end
    end


    methods(Access=private)

        function resetProperties(this)
            this.MyParentName='';
            this.MyChildName='';
            this.MyParentCS=[];
            this.MyChildCS=[];
            this.MyErrors.HadError=false;
            this.MyErrors.ErrMsg.message='';
            this.MyErrors.ErrMsg.identifier='';
            this.MyComponents={};
            this.MyDiffParams={};
            this.MyReporter=Simulink.ModelReference.internal.configset.DiagnosticReporter();
            this.MyDistrTargetWithHWNode=false;
            this.MyTargetType='RTW';
        end


        function parseInputs(obj,varargin)

            p=inputParser;
            p.addRequired('ParentModelName',@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.addRequired('ParentConfigSet',@(x)validateattributes(x,...
            {'Simulink.ConfigSet','Simulink.ConfigComponent'},{'nonempty'}));
            p.addRequired('ChildModelName',@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.addRequired('ChildConfigSet',@(x)validateattributes(x,...
            {'Simulink.ConfigSet','Simulink.ConfigComponent'},{'nonempty'}));
            p.addRequired('TargetType',@(x)any(validatestring(x,{'RTW','NONE'})));
            p.addParameter('Reporter',obj.MyReporter,@(x)validateattributes(x,...
            {'Simulink.ModelReference.internal.configset.ParentChildMismatchReporter'},{'nonempty'}));
            p.addParameter('Component','',@(x)validateattributes(x,{'char'},{'nonempty'}));
            p.parse(varargin{:});


            obj.MyParentName=p.Results.ParentModelName;
            obj.MyChildName=p.Results.ChildModelName;
            obj.MyParentCS=p.Results.ParentConfigSet;
            obj.MyChildCS=p.Results.ChildConfigSet;
            obj.MyReporter=p.Results.Reporter;
            obj.MyTargetType=p.Results.TargetType;
            obj.MySelectedComponent=p.Results.Component;


            obj.MyReporter.setComparator(obj);


            obj.MyDistrTargetWithHWNode=Simulink.DistributedTarget.isMappedToHardwareNode(...
            obj.MyChildName,obj.MyParentName);
        end



        function components=checkComponentCompatibility(obj)

            parentComp=obj.MyParentCS.getComponent('any',obj.MySelectedComponent);
            childComp=obj.MyChildCS.getComponent('any',obj.MySelectedComponent);
            components={};


            if isempty(parentComp)||isempty(childComp)
                obj.MyErrors.HadError=true;
                errMsg.identifier='Simulink:slbuild:componentNotFound';
                errMsg.message=DAStudio.message(errMsg.identifier,...
                obj.MySelectedComponent,obj.MyParentName,obj.MyChildName);
                obj.MyErrors.ErrMsg=errMsg;
                return;
            end


            aComp.Name=obj.MySelectedComponent;
            aComp.subComponents=[];
            components{end+1}=aComp;
        end




        function components=checkConfigsetCompatibility(obj,parentCS,childCS)
            namesParent=obj.getComponentNames(parentCS);
            namesChild=obj.getComponentNames(childCS);
            components={};



            [~,xorIndParent,xorIndChild]=setxor(namesParent,namesChild);
            [~,intersectIndParent,intersectIndChild]=intersect(namesParent,namesChild);


            parentComps=parentCS.Components(xorIndParent);
            arrayfun(@(x)(obj.checkUnmatchedComponent(x,...
            obj.MyParentName,obj.MyChildName)),parentComps);


            childComps=childCS.Components(xorIndChild);
            arrayfun(@(x)(obj.checkUnmatchedComponent(x,...
            obj.MyChildName,obj.MyParentName)),childComps);


            assert(length(intersectIndParent)==length(intersectIndChild));
            for i=1:length(intersectIndParent)
                compParent=parentCS.Components(intersectIndParent(i));
                compChild=childCS.Components(intersectIndChild(i));


                assert(compParent.skipModelReferenceComparison()==...
                compChild.skipModelReferenceComparison());


                if~compParent.skipModelReferenceComparison()

                    subComps=[];
                    if(~isempty(compParent.Components)||~isempty(compChild.Components))
                        subComps=obj.checkConfigsetCompatibility(compParent,compChild);
                    end


                    aComp.Name=compParent.Name;
                    aComp.subComponents=subComps;
                    components{end+1}=aComp;%#ok<AGROW>
                end
            end
        end


        function result=getComponentNames(~,aCS)
            result=arrayfun(@(x)(class(x)),aCS.Components,'UniformOutput',false);
        end


        function checkUnmatchedComponent(obj,comp,compModel,otherModel)
            if~(comp.skipModelReferenceComparison()||...
                comp.allowParentAndChildToHaveUnmatchedComponent())


                if isa(comp,'CoderTarget.SettingsController')&&...
                    ~isequal(get_param(obj.MyParentCS,'HardwareBoard'),...
                    get_param(obj.MyChildCS,'HardwareBoard'))
                    return;
                end

                cr=newline;
                obj.MyErrors.HadError=true;
                obj.MyErrors.ErrMsg.identifier='Simulink:slbuild:incompatibleConfigurationSets';
                obj.MyErrors.ErrMsg.message=[obj.MyErrors.ErrMsg.message,...
                DAStudio.message('Simulink:slbuild:unmatchedComponent',...
                comp.Name,class(comp),compModel,otherModel),cr,cr];
            end
        end


        function compareConfigsets(obj,parentCS,childCS,comps)
            for i=1:length(comps)

                try

                    compName=comps{i}.Name;
                    parentComp=parentCS.getComponent(compName);
                    childComp=childCS.getComponent(compName);




                    compFullName=obj.getComponentFullName(parentComp);
                    if obj.MyDistrTargetWithHWNode&&...
                        (isequal(compName,'Coder Target')||...
                        isequal(compName,'Hardware Implementation'))
                        diff={};
                    elseif obj.isCustomTargetComponent(parentComp)

                        diff=parentComp.compareComponentWithChild(childComp);
                    else


                        diff=obj.compareUsingDataModel(compName);





                        if~strcmp(compFullName,compName)
                            diffFullName=obj.compareUsingDataModel(compFullName);
                            diff=[diff,diffFullName{:}];%#ok<AGROW>
                        end
                    end


                    if~isempty(diff)
                        obj.MyDiffParams=horzcat(obj.MyDiffParams,diff{:});
                    end


                    if~isempty(comps{i}.subComponents)
                        obj.compareConfigsets(parentComp,childComp,comps{i}.subComponents);
                        if obj.MyErrors.HadError
                            return;
                        end
                    end
                catch myException

                    obj.MyErrors.HadError=true;
                    errMsg.identifier='Simulink:slbuild:incompatibleComponents';
                    errMsg.message=DAStudio.message(errMsg.identifier,...
                    parentComp.getFullName,obj.MyParentName,...
                    childComp.getFullName,obj.MyChildName,...
                    myException.message);
                    obj.MyErrors.ErrMsg=errMsg;
                    return;
                end

            end

        end



        function result=getComponentFullName(~,aComp)
            s=configset.internal.getConfigSetStaticData;
            staticCompObj=s.getComponent(class(aComp));
            if~isempty(staticCompObj)
                result=staticCompObj.FullName;
            else
                result=aComp.Name;
            end
        end



        function result=isCustomTargetComponent(~,aComp)
            result=isa(aComp,'Simulink.STFCustomTargetCC');
        end



        function diff=compareUsingDataModel(obj,compName)
            list=Simulink.ModelReference.internal.configset.ParentChildMatch.getParamsList(compName);
            ind=cellfun(@(x)(obj.isParamMismatched(x,compName)),list);
            diff=list(ind);
        end


        function result=isParamMismatched(obj,param,compName)
            result=false;


            paramObject=Simulink.ModelReference.internal.configset.ParentChildMatch.getParamStaticDataObject(param,compName);


            if~isempty(paramObject.function)
                result=feval(['configset.internal.custom.'...
                ,paramObject.function],obj.MyParentCS,obj.MyChildCS,param,obj.MyTargetType,obj.MyDistrTargetWithHWNode);
            elseif strcmp(paramObject.match,'on')

                topParam=get_param(obj.MyParentCS,param);
                childParam=get_param(obj.MyChildCS,param);
                result=~isequal(topParam,childParam);
            end
        end
    end
end


