import "package:flutter/material.dart";
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:your_key/bloc/auth_bloc.dart';
import 'package:your_key/bloc/main_menu_bloc.dart';
import 'package:your_key/localizations/localizations.dart';

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MainMenuBloc(BlocProvider.of<AuthenticationBloc>(context)),
        child: BlocBuilder<MainMenuBloc, List<MenuItem>>(
            builder: (context, menuItems) {
              return Drawer(
                child: Scaffold(
                  appBar: AppBar(
                    leading: Builder(
                      builder: (BuildContext context) {
                        return IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () {
                            //context.bloc<MainMenuBloc>().add(MainMenuEvent.mainpage);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                    title: Text(AppLocalizations.of(context).translate("menu")),
                  ),
                  body: _buildList(context, menuItems),
                ),
              );
            }
        )
    );
  }

  Widget _buildList(BuildContext context, List<MenuItem> menuItems) {
    return ListView(
      children: menuItems.map((item) => _buildListItem(context, item)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, MenuItem item) {

    if(item == null) {
      return Container();
    }
    return ListTile(
      leading: Icon(item.icon, color: Theme.of(context).accentColor),
      title: Text(AppLocalizations.of(context).translate(item.name)),
      onTap: () {
        context.bloc<MainMenuBloc>().add(item.event);
      },
    );
  }
}