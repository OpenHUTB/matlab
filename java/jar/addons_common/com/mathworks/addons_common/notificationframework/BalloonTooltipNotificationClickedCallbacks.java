// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   BalloonTooltipNotificationClickedCallbacks.java

package com.mathworks.addons_common.notificationframework;

import com.mathworks.util.ImplementorsCache;
import com.mathworks.util.ImplementorsCacheFactory;
import java.util.*;

// Referenced classes of package com.mathworks.addons_common.notificationframework:
//            BalloonTooltipNotificationClickedCallback

public final class BalloonTooltipNotificationClickedCallbacks extends Enum
{

    public static BalloonTooltipNotificationClickedCallbacks[] values()
    {
        return (BalloonTooltipNotificationClickedCallbacks[])$VALUES.clone();
    }

    public static BalloonTooltipNotificationClickedCallbacks valueOf(String s)
    {
        return (BalloonTooltipNotificationClickedCallbacks)Enum.valueOf(com/mathworks/addons_common/notificationframework/BalloonTooltipNotificationClickedCallbacks, s);
    }

    private BalloonTooltipNotificationClickedCallbacks(String s, int i)
    {
        super(s, i);
        balloonTooltipNotificationClickedCallbacks = null;
        Collection collection = ImplementorsCacheFactory.getInstance().getImplementors(com/mathworks/addons_common/notificationframework/BalloonTooltipNotificationClickedCallback);
        HashMap hashmap = new HashMap();
        BalloonTooltipNotificationClickedCallback balloontooltipnotificationclickedcallback;
        String s1;
        for(Iterator iterator = collection.iterator(); iterator.hasNext(); hashmap.put(s1, balloontooltipnotificationclickedcallback))
        {
            balloontooltipnotificationclickedcallback = (BalloonTooltipNotificationClickedCallback)iterator.next();
            s1 = balloontooltipnotificationclickedcallback.addOnTypeServiced().toLowerCase();
            if(hashmap.containsKey(s1))
                throw new RuntimeException((new StringBuilder()).append("Multiple BalloonTooltipNotificationClickedCallback Implementations found for Add-On type : ").append(s1).toString());
        }

        balloonTooltipNotificationClickedCallbacks = hashmap;
    }

    public BalloonTooltipNotificationClickedCallback getImplementerFor(String s)
    {
        if(balloonTooltipNotificationClickedCallbacks.containsKey(s.toLowerCase()))
            return (BalloonTooltipNotificationClickedCallback)balloonTooltipNotificationClickedCallbacks.get(s.toLowerCase());
        else
            throw new UnsupportedOperationException((new StringBuilder()).append("No implementor found for Add-On type: ").append(s).append(".").toString());
    }

    public static final BalloonTooltipNotificationClickedCallbacks INSTANCE;
    private Map balloonTooltipNotificationClickedCallbacks;
    private static final BalloonTooltipNotificationClickedCallbacks $VALUES[];

    static 
    {
        INSTANCE = new BalloonTooltipNotificationClickedCallbacks("INSTANCE", 0);
        $VALUES = (new BalloonTooltipNotificationClickedCallbacks[] {
            INSTANCE
        });
    }
}
