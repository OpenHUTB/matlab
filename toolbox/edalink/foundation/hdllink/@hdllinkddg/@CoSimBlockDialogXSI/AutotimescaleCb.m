function AutotimescaleCb(this,varargin)
















    isPushButton=(nargin==2);




    this.Autotimescale(isPushButton);


    if(isPushButton)
        dialog=varargin{1};




        dialog.resetSize(false);
        dialog.refresh();
    end



