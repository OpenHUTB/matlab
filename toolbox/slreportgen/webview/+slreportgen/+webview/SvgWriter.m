classdef SvgWriter<handle







    methods
        function h=SvgWriter(sys)
            if isa(sys,'Stateflow.Object')
                domain='Stateflow';
            else
                domain='Simulink';
            end

            svg=GLUE2.SvgWriter(domain,sys);
            svg.Decoration=slreportgen.webview.GroupDecoration;

            h.m_svg=svg;

            n=length(sys.getChildren());
            h.m_length=n;
        end

        function generate(h,svgFile,svgWriteArgs)

            if strcmp(get_param(0,"EditorModernTheme"),"on")
                svgWriteArgs.Theme="Modern";
            else
                svgWriteArgs.Theme="Classic";
            end


            svgWriteArgs.PathXStyle=get_param(0,'EditorPathXStyle');



            n=h.m_length;
            if(n>1500)
                svgWriteArgs.Theme='Classic';
                svgWriteArgs.PathXStyle='none';
            end

            svg=h.m_svg;

            svg.write(svgFile,svgWriteArgs);
        end

        function objList=getGroupedSlProxyObjs(h)
            deList=h.m_svg.Decoration.getGroupedDiagramElements();

            nList=deList.size();
            objList=cell(1,nList);
            j=1;
            for i=1:nList
                de=deList.at(i);
                bObj=resolveFromGLUE2DiagramElement(de);
                pObj=slreportgen.webview.SlProxyObject(bObj);
                hObj=getHandle(pObj);
                if(~isempty(hObj)&&(hObj~=-1))
                    objList{j}=pObj;
                    j=j+1;
                end
            end
            objList(j:end)=[];
        end
    end

    properties(Access=private)
        m_svg;
        m_length;
    end

end

function out=resolveFromGLUE2DiagramElement(in)
    switch class(in)
    case 'SLM3I.Diagram'
        out=get_param(in.getFullName(),'Handle');

    case{'SLM3I.Block','SLM3I.Annotation'}
        out=in.handle;

    case{'StateflowDI.Subviewer','StateflowDI.State','StateflowDI.Transition'}
        r=slroot();
        out=r.idToHandle(double(in.backendId));

    case 'SLM3I.Line'

        seg=get_param(in.segment.at(1).handle,'Object');
        out=getLine(seg);

    case 'StateflowDI.Port'
        r=slroot();
        out=r.idToHandle(double(in.backendId));


    otherwise
        error(message('slreportgen:utils:error:unexpectedType',class(in)));
    end
end