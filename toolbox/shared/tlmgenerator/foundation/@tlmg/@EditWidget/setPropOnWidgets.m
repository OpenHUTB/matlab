function setPropOnWidgets(h,propName,propVal)



    switch(propName)
    case{'Visible','Enabled','DialogRefresh'}
        h.labelW.(propName)=propVal;
        h.editW.(propName)=propVal;
    end

end
