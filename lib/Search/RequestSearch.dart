import 'package:flutter/material.dart';
import 'package:productdevelopment/Model/Request.dart';
import 'package:productdevelopment/Model/RequestSuggestions.dart';
import 'package:productdevelopment/Search/AssignedRejectedModelSearchResults.dart';
import 'package:productdevelopment/Search/ClientRequestSearchResultsList.dart';
import 'RequestSearchResultsList.dart';

class RequestSearch extends SearchDelegate<String>{
  List<RequestSuggestions> list=[];
  bool isClient=false,isAssignedRejection=false;
  int statusId,just;
   String result;
   String token;
   var currentUserRoles;
   List<Request> requests=[];

  RequestSearch(this.list,{this.isClient,this.statusId,this.currentUserRoles,this.token,this.just,this.isAssignedRejection});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon:Icon(Icons.clear),
      onPressed: (){
       query='';
      },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {

    return
      IconButton(
        icon:Icon(Icons.arrow_back),
        onPressed: (){
         close(context, result);
        },
      );
  }


  @override
  Widget buildResults(BuildContext context) {
    if(isAssignedRejection!=null&&isAssignedRejection){
      return AssignedRejectedModelSearchResults(
        query: query,
        token: token,
      );
    }
    if(statusId!=null&&statusId<=6&&just==null) {
      return RequestSearchResultsList(
        token: token,
        currentUserRoles: currentUserRoles,
        isClient: isClient,
        query: query,
        statusId: statusId,
      );
    }
    return ClientRequestSearchResultsList(
      token: token,
      currentUserRoles: currentUserRoles,
      isClient: isClient,
      query: query,
      statusId: statusId,
      just: just,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
   // print("Suggestions "+list.toString());
    final suggestions=list.where((element) =>element.suggestionText.toLowerCase().contains(query.toLowerCase()));

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context,int index)
      {
        return ListTile(
          title: Text(suggestions.elementAt(index).suggestionText),
          subtitle: Text(suggestions.elementAt(index).type),
          leading: Icon(Icons.search),
          onTap: (){
            query=suggestions.elementAt(index).suggestionText;
            showResults(context);
          },
        );
      },
    );
  }
}