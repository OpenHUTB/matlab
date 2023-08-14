classdef IconAction




    methods(Static)
        function cmds=insertTextIcon(mt)

            cmds=matlab.system.editor.internal.MethodAction.insert(mt,'getIconImpl',...
            'UseTextIcon',true);


            Lstart=cmds{end}.StartLine;
            Cstart=cmds{end}.StartColumn;
            defaultSpacesPerIndent=matlab.system.editor.internal.CodeTemplate.getSpacesPerIndent;
            CstartNew=Cstart+defaultSpacesPerIndent+length('icon = ''');
            cmds{end}=struct('Action','select',...
            'StartLine',Lstart+2,'StartColumn',CstartNew,...
            'EndLine',Lstart+2,'EndColumn',CstartNew+length('My System'));
        end

        function cmds=insertImageIcon(mt,imageFile)

            cmds=matlab.system.editor.internal.MethodAction.insert(mt,'getIconImpl',...
            'IconImageFile',imageFile);
        end

        function chooser=chooseImageIcon(chooser,filePath,callback)
            needsLaunch=isempty(chooser)||~ishandle(chooser);
            if needsLaunch
                chooser=matlab.system.editor.internal.imageFileChooser(filePath,callback);
            else
                chooser.show();
            end
        end

        function iconExpr=getIconExpression(mt)


            iconExpr=[];
            classdefNode=mtfind(mt,'Kind','CLASSDEF');
            methodNode=matlab.system.editor.internal.ParseTreeUtils.getMethodNode(classdefNode,'getIconImpl');
            if~isempty(methodNode)

                outputVar=string(methodNode.Outs);
                iconAssignmentNodes=mtfind(subtree(methodNode),'Kind','EQUALS','Left.String',outputVar);
                if~isnull(iconAssignmentNodes)
                    ind=iconAssignmentNodes.indices;



                    if numel(ind)>1
                        iconExpr=[];
                    else
                        iconAssignmentNode=iconAssignmentNodes.select(ind);
                        iconExpr=tree2str(iconAssignmentNode.Right);
                    end
                end
            end
        end

        function cleanup(chooser)
            if~isempty(chooser)&&ishandle(chooser)
                delete(chooser);
            end
        end
    end
end

