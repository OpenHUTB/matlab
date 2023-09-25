// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   MLServices.java

package com.mathworks.mlservices;

import java.lang.reflect.Method;

class MLServices
{

    MLServices()
    {
    }

    protected static Object getRegisteredService(String s, String s1)
    {
        Object obj = null;
        try
        {
            Class class1 = Class.forName(s);
            if(class1 != null)
            {
                Object obj1 = class1.newInstance();
                if(obj1 != null)
                {
                    Method method = class1.getMethod(s1, new Class[0]);
                    if(method != null)
                        obj = method.invoke(obj1, new Object[0]);
                }
            }
        }
        catch(Exception exception) { }
        return obj;
    }
}
