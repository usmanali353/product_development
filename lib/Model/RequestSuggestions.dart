class RequestSuggestions{
  String suggestionText;
  String type;

  RequestSuggestions(this.suggestionText,this.type);

  @override
  String toString() {
    return 'RequestSuggestions{suggestionText: $suggestionText, type: $type}';
  }
}