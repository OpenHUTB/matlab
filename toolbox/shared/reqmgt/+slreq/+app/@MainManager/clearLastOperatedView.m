function clearLastOperatedView(this,spObj)



    if(isempty(this.lastOperatedView)&&isempty(spObj))||any(this.lastOperatedView==spObj)
        this.lastOperatedView=[];
    end

end