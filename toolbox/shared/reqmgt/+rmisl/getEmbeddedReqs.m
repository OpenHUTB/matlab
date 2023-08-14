function result=getEmbeddedReqs(objH,isSf,isSigBuilder,varargin)




    if nargin==1||isempty(isSf)
        [modelH,objH,isSf,isSigBuilder]=rmisl.resolveObj(objH);
    else
        if isSf
            modelH=rmisf.getmodelh(objH);
        else
            modelH=bdroot(objH);
        end
        if nargin<3
            isSigBuilder=~isSf&&rmisl.is_signal_builder_block(objH);
        end
    end


    reqsStr=rmi.getRawReqs(objH,isSf);


    reqs=rmi.parsereqs(reqsStr);


    if~isempty(reqs)
        switch length(varargin)
        case 1
            index=varargin{1};
            if isSigBuilder
                [offset,count]=rmisl.sigbuilder_group_reqs(objH,index);
                reqs=rmi.filterReqs(reqs,offset,count);
            else
                error(message('Slvnv:getReqs:InvalidArgs'));
            end
        case 2
            offset=varargin{1};
            count=varargin{2};
            reqs=rmi.filterReqs(reqs,offset,count);
        otherwise

        end
    end



    if isempty(reqs)
        result=[];
    elseif isSf&&isDisabledLibLink(objH)
        result=reqs;
    else
        result=rmisl.intraLinksResolve(reqs,modelH);
    end
end

function yesno=isDisabledLibLink(h)

    chartId=obj_chart(h);
    sfRoot=sfroot();
    linkStatus=get_param(sfRoot.idToHandle(chartId).Path,'StaticLinkStatus');
    yesno=strcmp(linkStatus,'inactive');
end


