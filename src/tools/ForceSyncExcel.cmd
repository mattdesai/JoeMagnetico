@echo off
echo Force syncing excel sheets when forms are submitted...
echo.
echo JM https://sl5wg-my.sharepoint.com/:x:/r/personal/golfpooladmin_sl5wg_onmicrosoft_com/Documents/2026%20British%20Open%20Golf%20Pool%20Entry%20Form%20-%20JM.xlsx?d=w6cad40a724d145c19cf20d97e5d6ed7d
echo MI https://sl5wg-my.sharepoint.com/:x:/r/personal/golfpooladmin_sl5wg_onmicrosoft_com/Documents/2026%20British%20Open%20Golf%20Pool%20Entry%20Form%20-%20Micro.xlsx?d=w2416140c2ee2402a92b3fb3fb81b2ed8
echo.

:top

if exist "\Users\mattd\OneDrive - MSFT\JMForm.txt" (

   echo %date% %time% - JM
   start "" "https://sl5wg-my.sharepoint.com/:x:/r/personal/golfpooladmin_sl5wg_onmicrosoft_com/Documents/2026%20British%20Open%20Golf%20Pool%20Entry%20Form%20-%20JM.xlsx?d=w6cad40a724d145c19cf20d97e5d6ed7d&csf=1&web=1&e=ybAbe5"

   del "\Users\mattd\OneDrive - MSFT\JMForm.txt" 
)


if exist "\Users\mattd\OneDrive - MSFT\MicroForm.txt" (

   echo %date% %time% - Micro
   start "" "https://sl5wg-my.sharepoint.com/:x:/r/personal/golfpooladmin_sl5wg_onmicrosoft_com/Documents/2026%20British%20Open%20Golf%20Pool%20Entry%20Form%20-%20Micro.xlsx?d=w2416140c2ee2402a92b3fb3fb81b2ed8&csf=1&web=1&e=BjUF3l"

   del "\Users\mattd\OneDrive - MSFT\MicroForm.txt"
)

powershell -command start-sleep 120

goto :top
