function[err,varargout]=genData(varargin)

%#codegen
    coder.allowpcode('plain');

    coder.extrinsic('evalin');
    coder.extrinsic('num2str');
    coder.extrinsic('hsb.blkcb2.genFrameData');
    modes={'random','counter','ones','workspace'};
    persistent tnum

    gd_chwidth=varargin{1};
    gd_chlen=varargin{2};
    gd_exemplar=varargin{3};
    gd_vblename=cast(varargin{5}(1:nnz(varargin{5})),'char')';
    gd_mode=varargin{end};
    smode=modes{gd_mode};
    gd_cntrinitvalue=varargin{4};
    if(isempty(tnum))
        tnum=0;
        if strcmpi(smode,'workspace')
            evalin('base',[gd_vblename,'Temp=reshape(',gd_vblename,',[numel(',gd_vblename,'),1]);']);
        end
    end
    if strcmpi(smode,'workspace')
        da=evalin('base',...
        [gd_vblename,'Temp(1:',num2str(gd_chlen),')']);
        evalin('base',...
        [gd_vblename,'Temp=','circshift(',gd_vblename,'Temp,','-',num2str(gd_chlen),');']);
        err=0;
    else
        [da,err]=hsb.blkcb2.genFrameData(gd_chlen,...
        gd_exemplar,gd_chwidth,tnum,gd_cntrinitvalue,smode);
    end
    tnum=tnum+1;
    [varargout{1:nargout-1}]=cast(da,'like',gd_exemplar);
end
