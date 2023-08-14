function cvt=get(this,modelName)






    cvt=[];


    modelName=convertStringsToChars(modelName);

    if this.m_data.isKey(modelName)
        cvt=cvtest(this.m_data(modelName));
    end
