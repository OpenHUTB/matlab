classdef(Sealed,Hidden)Edge<handle


















    properties


        SourcePort(1,1)Simulink.internal.variantlayout.Port;


        DstPort(1,1)Simulink.internal.variantlayout.Port;


        SourceBlock(1,:)char;


        DstBlock(1,:)char;


        Points(:,2)double;


        NumberOfBends(1,1)double=0;


        HasHyperEdge(1,1)logical=0;
    end

    methods


        function obj=Edge(srcPortobj,dstPortobj)

            if nargin>0
                obj.SourcePort=srcPortobj;
                obj.DstPort=dstPortobj;

                obj.SourceBlock=srcPortobj.ParentNode;
                obj.DstBlock=dstPortobj.ParentNode;

                lineout=get(srcPortobj.PortHandle,'Line');
                linein=get(dstPortobj.PortHandle,'Line');

                if isequal(lineout,linein)
                    obj.HasHyperEdge=0;
                    obj.Points=get(lineout,'Points');
                else
                    obj.HasHyperEdge=1;
                    tmp_points1=get(lineout,'Points');
                    tmp_points2=get(linein,'Points');
                    obj.Points=unique([tmp_points1;tmp_points2],'rows');
                end


                for ii=1:size(obj.Points,1)-2
                    s1=[obj.Points(ii+1,1)-obj.Points(ii,1),obj.Points(ii+1,2)-obj.Points(ii,2)];
                    s2=[obj.Points(ii+2,1)-obj.Points(ii+1,1),obj.Points(ii+2,2)-obj.Points(ii+1,2)];
                    if(s1*(s2')<eps)
                        obj.NumberOfBends=obj.NumberOfBends+1;
                    end
                end

            end
        end
    end
end


