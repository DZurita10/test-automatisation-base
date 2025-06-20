Feature: Marvel Characters API Tests

  Background:
    # Configuración base para todas las pruebas
    * url 'http://bp-se-test-cabcd9b246a5.herokuapp.com/dazurita/api/characters'
    * def schema =
      """
      {
        "id": "#number",
        "name": "#string",
        "alterego": "#string",
        "description": "#string",
        "powers": "#array"
      }
      """

  # Escenario 1: Obtener todos los personajes
    @GETALL
  Scenario: Obtener todos los personajes
    When method GET
    Then status 200
    And match response == "#array"

    * def validateEach = function(x) { karate.match(x, schema).pass }
    * karate.forEach(response, validateEach)

  # Escenario 2: Obtener personaje por ID (exitoso)
    @GETBYID
  Scenario: Obtener personaje por ID (exitoso)
    Given path '2'
    When method GET
    Then status 200
    And match response == schema
    And response.id == 2

  # Escenario 3: Obtener personaje por ID (no existe)
    @GETBYIDWITHERROR
  Scenario: Obtener personaje por ID (no existe)
    Given path '9999898'
    When method GET
    Then status 404
    And match response ==
      """
      {
        "error": "Character not found"
      }
      """
    And match response.error == 'Character not found'

  # Escenario 4: Crear personaje (exitoso)
    @CREATE
  Scenario: Crear personaje (exitoso)
    Given request
      """
      {
        "name": "Alexander Zurita",
        "alterego": "Alex",
        "description": "Poderoso",
        "powers": ["Fuerte"]
      }
      """
    And header Content-Type = 'application/json'
    When method POST
    Then status 201
    And match response contains
      """
      {
        "name": "Alexander Zurita",
        "alterego": "Alex",
        "description": "Poderoso",
        "powers": ["Fuerte"]
      }
      """
    And match response == schema

  # Escenario 5: Crear personaje (nombre duplicado)
    @CREATEWITHERROR
  Scenario: Crear personaje (nombre duplicado)
    Given request
      """
      {
        "name": "Iron Man",
        "alterego": "Otro",
        "description": "Otro",
        "powers": ["Armor"]
      }
      """
    And header Content-Type = 'application/json'
    When method POST
    Then status 400
    And match response ==
      """
      {
        "error": "Character name already exists"
      }
      """
    And match response.error == 'Character name already exists'

  # Escenario 6: Crear personaje (faltan campos requeridos)
    @CREATEWITHERROR
  Scenario: Crear personaje (faltan campos requeridos)
    Given request
      """
      {
        "name": "",
        "alterego": "",
        "description": "",
        "powers": []
      }
      """
    And header Content-Type = 'application/json'
    When method POST
    Then status 400
    And match response ==
      """
      {
        "name": "Name is required",
        "alterego": "Alterego is required",
        "description": "Description is required",
        "powers": "Powers are required"
      }
      """

  # Escenario 7: Actualizar personaje (exitoso)
    @UPDATE
  Scenario: Actualizar personaje (exitoso)
    Given path '15'
    And request
      """
      {
        "name": "DZ598",
        "alterego": "diego",
        "description": "Updated description",
        "powers": ["Super fuerza"]
      }
      """
    And header Content-Type = 'application/json'
    When method PUT
    Then status 200
    And match response contains
      """
      {
        "name": "DZ598",
        "alterego": "diego",
        "description": "Updated description",
        "powers": ["Super fuerza"]
      }
      """
    And match response == schema

  # Escenario 8: Actualizar personaje (no existe)
    @UPDATEWITHERROR
  Scenario: Actualizar personaje (no existe)
    Given path '9998798'
    And request
      """
      {
        "name": "DZ598",
        "alterego": "diego",
        "description": "Updated description",
        "powers": ["Super fuerza"]
      }
      """
    And header Content-Type = 'application/json'
    When method PUT
    Then status 404
    And match response ==
      """
      {
        "error": "Character not found"
      }
      """
    And match response.error == 'Character not found'

  # Escenario 9: Eliminar personaje (exitoso)
    @DELETE
  Scenario: Eliminar personaje (exitoso)
    Given path '15'
    When method DELETE
    Then status 204
    And match response == ''

  # Escenario 10: Eliminar personaje (no existe)
    @DELETEWITHERROR
  Scenario: Eliminar personaje (no existe)
    Given path '999879745'
    When method DELETE
    Then status 404
    And match response ==
      """
      {
        "error": "Character not found"
      }
      """
    And match response.error == 'Character not found'
