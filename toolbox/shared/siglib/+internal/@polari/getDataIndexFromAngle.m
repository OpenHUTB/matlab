function idx=getDataIndexFromAngle(p,ang,datasetIndex)








    pdata=getDataset(p,datasetIndex);
    if isempty(pdata)||isempty(pdata.ang)
        idx=[];
    else


        th_pt=getNormalizedAngle(p,ang);
        cplx_pt=complex(cos(th_pt),sin(th_pt));




        th_all=getNormalizedAngle(p,pdata.ang);
        cplx_all=complex(cos(th_all),sin(th_all));

        [~,idx]=min(abs(bsxfun(@minus,cplx_pt,cplx_all)));
    end
