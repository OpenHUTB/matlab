function im1=stencil_sim(func,im,nhood,shape,varargin)



    additional_params=varargin;
    pStruct=gpucoder.internal.getStencilParams(func,im,nhood,shape,...
    additional_params);

    IN=size(pStruct.input);
    [ON,padidx]=getSizes(IN,pStruct.window,pStruct.shape,numel(IN));

    im1=stencil2D(pStruct.fHandle,...
    pStruct.input,...
    ON(2),...
    ON(1),...
    IN(2),...
    IN(1),...
    pStruct.window(2),...
    pStruct.window(1),...
    padidx(2),...
    padidx(1),...
    pStruct.parameters);


end


function[ON,padidx]=getSizes(IN,window,shape,numDims)

    ON=[0,0];
    padidx=[0,0];
    switch lower(shape)
    case 'same'
        for k=1:numDims
            padidx(k)=0;
            ON(k)=IN(k);
        end
    case 'full'
        for k=1:numDims
            padidx(k)=floor(window(k)/2);
            ON(k)=IN(k)+window(k)-1;
        end
    case 'valid'
        for k=1:numDims
            padidx(k)=-floor((window(k)-1)/2);
            ON(k)=IN(k)-window(k)+1;
            if ON(k)<0
                ON(k)=0;
            end
        end
    otherwise
        error(message('gpucoder:common:InvalidShape','same, valid or full'));
    end

end


function Op=stencil2D(func,im,OW,OH,IW,IH,KW,KH,padW,padH,params)

    if(OW==0)||(OH==0)
        Op=zeros(OH,OW);
        return;
    end

    assert(isequal(size(im,1),IH)&&isequal(size(im,2),IW));


    offsetW=padW+floor((double(KW)-1)/2);
    offsetH=padH+floor((double(KH)-1)/2);

    expanded=zeros(OH+KH-1,OW+KW-1,'like',im);
    expanded(offsetH+(1:IH),offsetW+(1:IW))=im;
    rows=0:KH-1;
    cols=0:KW-1;


    ocol=1;
    orow=1;
    newIm=expanded(ocol+rows,orow+cols);
    cv=func(newIm,params{:});
    assert(isscalar(cv),...
    message('gpucoder:common:StencilInvalidFunctionHandleOutput'));

    Op=zeros(OH,OW,'like',cv);
    Op(orow,ocol)=cv;

    parfor orow=2:OH
        rowIdx=orow;
        newIm=expanded(rowIdx:rowIdx+KH-1,ocol:ocol+KW-1);

        cv=func(newIm,params{:});
        Op(orow,ocol)=cv;
    end

    parfor ocol=2:OW
        colIdx=ocol;
        for orow=1:OH
            rowIdx=orow;
            newIm=expanded(rowIdx:rowIdx+KH-1,colIdx:colIdx+KW-1);

            cv=func(newIm,params{:});
            Op(orow,ocol)=cv;
        end
    end
end
