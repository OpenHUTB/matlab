



classdef SFAstIdentifier<slci.ast.SFAst

    properties
        fName='';
        fOrigName='';
        fTime=false;
        fCustomData=false;
        fFalse=false;
        fId='';
        fTrue=false;
    end

    methods

        function aObj=SFAstIdentifier(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            if isa(aAstObj,'mtree')


                aObj.fName=aAstObj.string;
                aObj.fOrigName=aAstObj.string;
                owner=aObj.getRootAstOwner;
                if isa(owner,'slci.stateflow.Transition')...
                    ||isa(owner,'slci.stateflow.SFState')...
                    ||isa(owner,'slci.stateflow.TruthTable')
                    chart=owner.ParentChart;
                    aObj.fName=[chart.getSID(),':',aAstObj.string];
                    parent=owner.getParent;
                    qualifiedName='';%#ok<NASGU>
                    if isa(parent,'slci.stateflow.SFFunction')

                        path=strrep(chart.Path,newline,' ');

                        full_func_name=strrep(slci.internal.getFullSFObjectName(parent.getSID),'.','/');
                        key=fullfile(path,full_func_name,aObj.fName);
                        qualifiedName=chart.findQualifiedName(key);





                        if isempty(qualifiedName)

                            key=fullfile(path,aObj.fName);
                            qualifiedName=chart.findQualifiedName(key);
                        end
                    elseif isa(parent,'slci.stateflow.SFState')

                        path=strrep(chart.Path,newline,' ');
                        key=fullfile(path,aObj.fName);
                        qualifiedName=chart.findQualifiedName(key);
                        if isempty(qualifiedName)

                            key=fullfile(path,aObj.fName);
                            qualifiedName=chart.findQualifiedName(key);
                        end
                    elseif isa(owner,'slci.stateflow.TruthTable')

                        path=strrep(owner.getPath(),newline,' ');

                        key=fullfile(path,owner.getName(),aObj.fName);
                        qualifiedName=chart.findQualifiedName(key);
                        if isempty(qualifiedName)


                            key=fullfile(path,aObj.fName);
                            qualifiedName=chart.findQualifiedName(key);
                        end
                    else

                        key=fullfile(strrep(parent.Path,newline,' '),aObj.fName);
                        qualifiedName=chart.findQualifiedName(key);
                    end


                    aObj.fId=0;
                    nameIdMap=chart.getNameIdMap();
                    if isKey(nameIdMap,qualifiedName)
                        aObj.fName=qualifiedName;
                        aObj.fId=nameIdMap(qualifiedName);
                    end
                end
            else
                aObj.fName=aAstObj.sourceSnippet;
                aObj.fOrigName=aObj.fName;
                aObj.setTime(aAstObj.id);
                aObj.setCustomData(aAstObj.id);
                aObj.fId=aAstObj.id;
                aObj.setTrueFalse();
            end
        end


        function out=getIdentifier(aObj)
            out=aObj.getQualifiedName();
            if isempty(out)


                out=aObj.fName;
            end
        end


        function out=getOrigName(aObj)
            out=aObj.fOrigName;
        end

        function out=IsFalse(aObj)
            out=aObj.fFalse;
        end

        function out=IsTrue(aObj)
            out=aObj.fTrue;
        end


        function out=getId(aObj)
            out=aObj.fId;
        end

        function ComputeDataType(aObj)
            assert(~aObj.fComputedDataType);
            if aObj.fFalse||aObj.fTrue
                aObj.setDataType('boolean');
                return;
            end

            rt=sfroot;
            if aObj.fId>0
                sfObj=rt.idToHandle(aObj.fId);
                if isa(sfObj,'Stateflow.Data')



                    if sfObj.SSIdNumber==0||...
                        strcmpi(sfObj.Scope,'Imported')||...
                        strcmpi(sfObj.Scope,'Exported')||...
                        strcmpi(sfObj.up.class,'Simulink.BlockDiagram')
                        aObj.setDataType(sfObj.CompiledType);



                    else
                        chartSLHandle=aObj.ParentBlock.getHandle;
                        dpi=sf('DataParsedInfo',aObj.fId,chartSLHandle);
                        aObj.setDataType(dpi.compiled.type);
                    end
                    return;
                end
            end

            identifier=aObj.getIdentifier;
            if isa(aObj.ParentChart,'slci.stateflow.Chart')...
                &&strcmpi(slci.internal.getLanguageFromSFObject(aObj.ParentChart),'MATLAB')
                identifier=aObj.getOrigName;
            end

            if isa(aObj.getParent(),'slci.ast.SFAstDot')...
                &&Simulink.data.isSupportedEnumClass(identifier)
                aObj.setDataType(identifier);
            end








            if isa(aObj.ParentChart,'slci.stateflow.Chart')...
                &&isa(aObj.fRootAst,'slci.ast.SFAstMatlabFunctionDef')...
                &&isa(aObj.getRootAstOwner,'slci.stateflow.TruthTable')
                aObj.setDataType('boolean');
                return;
            end
        end

        function ComputeDataDim(aObj)
            assert(~aObj.fComputedDataDim);
            if aObj.fFalse||aObj.fTrue
                aObj.setDataDim([1,1]);
                return;
            end

            rt=sfroot;
            if aObj.fId>0
                sfObj=rt.idToHandle(aObj.fId);
                if isa(sfObj,'Stateflow.Data')



                    if sfObj.SSIdNumber==0||...
                        strcmpi(sfObj.Scope,'Imported')||...
                        strcmpi(sfObj.Scope,'Exported')
                        aObj.setDataDim(str2double(sfObj.CompiledSize));



                    else
                        chartSLHandle=aObj.ParentBlock.getHandle;
                        dpi=sf('DataParsedInfo',aObj.fId,chartSLHandle);

                        if~isempty(dpi.compiled.size)
                            dims=str2num(dpi.compiled.size);%#ok
                            datadim=dims;

                            if numel(datadim)==1
                                datadim=[datadim,1];
                            end
                        else



                            datadim=dpi.size;
                        end

                        aObj.setDataDim(datadim);
                    end
                    return;
                end
            end

            if isa(aObj.getParent(),'slci.ast.SFAstDot')...
                &&Simulink.data.isSupportedEnumClass(aObj.getIdentifier)
                aObj.setDataDim([1,1]);
            end
        end

    end

    methods(Access=protected)

        function setCustomData(aObj,aId)




            aObj.fCustomData=(aId==0)&&...
            ~strcmp(aObj.fName,'t')&&...
            ~strcmp(aObj.fName,'false')&&...
            ~strcmp(aObj.fName,'true')&&...
            ~isa(aObj.fParent,'slci.ast.SFAstStructMember');

        end

        function setTime(aObj,aId)

            aObj.fTime=(aId==0)&&strcmp(aObj.fName,'t');
        end

        function setTrueFalse(aObj)



            aObj.fFalse=strcmp(aObj.fName,'false')&&(aObj.fId==0);
            aObj.fTrue=strcmp(aObj.fName,'true')&&(aObj.fId==0);
        end

        function out=IsTime(aObj)
            out=aObj.fTime;
        end

        function out=IsCustomData(aObj)
            out=aObj.fCustomData;
        end

    end


    methods(Access=protected)


        function addMatlabFunctionConstraints(aObj)

            newConstraints=cell(1,4);
            newConstraints{1}=...
            slci.compatibility.MatlabFunctionMissingDimConstraint;
            newConstraints{2}=...
            slci.compatibility.MatlabFunctionMissingDatatypeConstraint;
            newConstraints{3}=...
            slci.compatibility.MatlabFunctionDatatypeConstraint;
            newConstraints{4}=...
            slci.compatibility.MatlabFunctionDimConstraint(...
            {'Scalar','Vector','Matrix'});
            aObj.setConstraints(newConstraints);
            addMatlabFunctionConstraints@slci.ast.SFAst(aObj);
        end

    end

end


