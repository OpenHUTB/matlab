function addinfinitegp(obj,usebaseunits)

    if nargin==1
        usebaseunits=0;
    end

    if strcmpi(class(obj),'infiniteArray')
        return;
    end

    if strcmpi(class(obj),'planeWaveExcitation')
        val=isinfGP(obj.Element);
        infGPbool=max(val,obj.MesherStruct.infGP);
    else
        infGPbool=isinfGP(obj);
    end


    if iscell(obj.MesherStruct.Geometry)
        if~isfield(obj.MesherStruct.Geometry{1},'multiplier')||usebaseunits==1
            mul=1;
        else
            mul=obj.MesherStruct.Geometry{1}.multiplier;
        end
        xmax=max(cellfun(@(x)(max(x.('BorderVertices')(:,1))),obj.MesherStruct.Geometry,'UniformOutput',true));
        ymax=max(cellfun(@(x)(max(x.('BorderVertices')(:,2))),obj.MesherStruct.Geometry,'UniformOutput',true));
        zmax=max(cellfun(@(x)(max(x.('BorderVertices')(:,3))),obj.MesherStruct.Geometry,'UniformOutput',true));
    else
        if~isfield(obj.MesherStruct.Geometry,'multiplier')||usebaseunits==1
            mul=1;
        else
            mul=obj.MesherStruct.Geometry.multiplier;
        end
        xmax=max(obj.MesherStruct.Geometry.BorderVertices(:,1));
        ymax=max(obj.MesherStruct.Geometry.BorderVertices(:,2));
        zmax=max(obj.MesherStruct.Geometry.BorderVertices(:,3));
    end

    feedwidth=max(getFeedWidth(obj));
    if isempty(feedwidth)
        feedwidth=0;
    end

    if isDielectricSubstrate(obj)
        xmax=max([xmax,obj.Substrate.Length]);
        ymax=max([ymax,obj.Substrate.Width]);
        zmax=max([zmax,obj.Substrate.Thickness]);
    end

    makePatchForInfGPGeometry(infGPbool,xmax*mul,ymax*mul,zmax*mul,feedwidth*mul)

end

function makePatchForInfGPGeometry(isInfGP,xmax,ymax,zmax,feedwidth)

    if isInfGP
        maxval=2*max(abs(xmax),abs(ymax));
        maxval=max(maxval,zmax);
        if~isscalar(feedwidth)
            feedwidth=max(feedwidth);
        end
        if abs(zmax)<1e-15
            zmax=feedwidth;
        end

        axis([-maxval,maxval,-maxval,maxval,-1.5*feedwidth,1.1*zmax]);
        xpatch=[-maxval,maxval,maxval,-maxval];
        ypatch=[-maxval,-maxval,maxval,maxval];
        zpatch=[0,0,0,0];
        hpatch=patch(xpatch,ypatch,zpatch,[0.8,0.9,1.0],'EdgeColor',...
        'b','LineStyle','--','LineWidth',1);
        set(hpatch,'DisplayName','infinite ground');






        ax=findobj(gcf,'type','axes');
        if isempty(ax(1).XTick)
            if(max(ax(1).YTick)>0.8*maxval)
                ax(1).XTick=ax(1).YTick;
                ax(1).XTickLabel=ax(1).YTickLabel;
            else
                points=linspace(-maxval,maxval,5);
                ax(1).XTick=points;
                ax(1).XTickLabel=num2str(points.');
                ax(1).YTick=points;
                ax(1).YTickLabel=num2str(points.');
            end
        elseif isempty(ax(1).YTick)
            if(max(ax(1).XTick)>0.8*maxval)
                ax(1).YTick=ax(1).XTick;
                ax(1).YTickLabel=ax(1).XTickLabel;
            else
                points=linspace(-maxval,maxval,5);
                ax(1).XTick=points;
                ax(1).XTickLabel=num2str(points.');
                ax(1).YTick=points;
                ax(1).YTickLabel=num2str(points.');
            end
        elseif(max(ax(1).XTick)<0.8*maxval)&&(max(ax(1).YTick)>0.8*maxval)
            ax(1).XTick=ax(1).YTick;
            ax(1).XTickLabel=ax(1).YTickLabel;
        elseif(max(ax(1).YTick)<0.8*maxval)&&(max(ax(1).XTick)>0.8*maxval)
            ax(1).YTick=ax(1).XTick;
            ax(1).YTickLabel=ax(1).XTickLabel;
        else
            points=linspace(-maxval,maxval,5);
            ax(1).XTick=points;
            ax(1).XTickLabel=num2str(points.');
            ax(1).YTick=points;
            ax(1).YTickLabel=num2str(points.');
        end
        if isempty(ax(1).ZTick)
            vals=[0,zmax];
            ax(1).ZTick=vals;
            ax(1).ZTickLabel=num2str(vals.');
        end

    end
end

function out=isinfGP(obj)

    if isprop(obj,'Element')
        if isscalar(obj.Element)
            val1=obj.Element.MesherStruct.infGP;
            val2=obj.MesherStruct.infGP;
            out=max(val1,val2);
        elseif iscell(obj.Element)
            val=zeros(1,numel(obj.Element));
            for m=1:numel(obj.Element)
                val(m)=obj.Element{m}.MesherStruct.infGP;
            end
            val1=any(val);
            val2=obj.MesherStruct.infGP;
            out=max(val1,val2);
        else
            val=zeros(1,numel(obj.Element));
            for m=1:numel(obj.Element)
                val(m)=obj.Element(m).MesherStruct.infGP;
            end
            val1=any(val);
            val2=obj.MesherStruct.infGP;
            out=max(val1,val2);
        end
    elseif isprop(obj,'Exciter')
        val1=obj.Exciter.MesherStruct.infGP;
        val2=obj.MesherStruct.infGP;
        out=max(val1,val2);
    else
        out=obj.MesherStruct.infGP;
    end
end