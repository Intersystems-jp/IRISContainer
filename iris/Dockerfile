FROM 'containers.intersystems.com/intersystems/iris:latest-em'
WORKDIR /opt/app

COPY ./Installer.cls ./
COPY ./cls/ ./src/

RUN iris start $ISC_PACKAGE_INSTANCENAME quietly EmergencyId=sys,sys && \
    /bin/echo -e "sys\nsys\n" \
            # ユーザー管理者に %ALL を付与
            "Do ##class(Security.Users).UnExpireUserPasswords(\"*\")\n" \
            "Do ##class(Security.Users).AddRoles(\"admin\", \"%ALL\")\n" \
            # インストーラのインポートと実行
            "Do \$system.OBJ.Load(\"/opt/app/Installer.cls\",\"ck\")\n" \
            "Set sc = ##class(App.Installer).setup(, 3)\n" \
            "If 'sc do \$zu(4, \$JOB, 1)\n" \
            "halt" \
    | iris session $ISC_PACKAGE_INSTANCENAME && \
    /bin/echo -e "sys\nsys\n" \
    | iris stop $ISC_PACKAGE_INSTANCENAME quietly

CMD [ "-l", "/usr/irissys/mgr/messages.log" ]
