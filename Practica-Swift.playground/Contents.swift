import Foundation

struct Client {
    let name: String
    let age: Int
    let height: Double
}

struct Reservation {
    var id: Int
    let hotelName: String
    let clientList: [Client]
    let duration: Int
    let price: Double
    let breakfast: Bool
}

enum ReservationError: Error {
    case repeatedID
    case repeatedClient
    case noReservation
}


class HotelReservationManager {
    
    private var idNumber = 0
    let hotelName = "Luchadores"
    private(set) var reservationList: [Reservation] = []
    
    // Creo un método para añadir una reserva
    
    func addReservation(clientList: [Client], duration: Int, breakfast: Bool) throws -> Reservation {
        
        idNumber += 1
        
        // Calculo el precio total
        
        let basePrice = 20.0
        var breakfastPrice: Double = 0.00
        
        if breakfast == true {
            breakfastPrice = 1.25
        } else {
            breakfastPrice = 1
        }
        
        let totalPrice = Double(clientList.count) * basePrice * Double(duration) * breakfastPrice
        
        let newReservation = Reservation(id: idNumber, hotelName: hotelName, clientList: clientList, duration: duration, price: totalPrice, breakfast: breakfast)
        
        // Verifico que el ID no se repite
        
        for reservation in reservationList {
            if reservation.id == idNumber {
                print("This ID already exists")
                throw ReservationError.repeatedID
            }
        }
        
        // Verifico que el cliente no está repetido en otra reserva
        
        for reservation in reservationList {
            for client in reservation.clientList {
                for client2 in clientList {
                    if client.name == client2.name {
                        print("The client already has another reservation")
                        throw ReservationError.repeatedClient
                    }
                }
            }
        }
        
        // Añado la reserva al listado de reservas.
        
        reservationList.append(newReservation)
        
        //Devuelvo la reserva
        
        return newReservation
    }
    
    // Creo un método para cancelar una reserva
    
    func cancelReservation(reservationIdToRemove id: Int) throws {
        
        guard let numberId = reservationList.firstIndex(where: {$0.id == id}) else {
            throw ReservationError.noReservation
        }

        reservationList.remove(at: numberId)
        
    }
    
    // Creo un método para obtener un listado de todas las reservas actuales
    
    func ListOfReservations () -> Array<Reservation> {
        return hotelManager.reservationList
    }
}

// Tests

let hotelManager = HotelReservationManager()

let Goku = Client(name: "Goku", age: 40, height: 1.85)
let Vegeta = Client(name: "Vegeta", age: 38, height: 1.75)
let Bardock = Client(name: "Bardock", age: 42, height: 1.83)
let Cell = Client(name: "Cell", age: 65, height: 2.10)
let Gohan = Client(name: "Gohan", age: 23, height: 1.75)

let Reservation1 = try hotelManager.addReservation(clientList: [Goku], duration: 1, breakfast: true)
let Reservation2 = try hotelManager.addReservation(clientList: [Vegeta], duration: 5, breakfast: true)
let Reservation3 = try hotelManager.addReservation(clientList: [Bardock], duration: 3, breakfast: false)
let Reservation4 = try hotelManager.addReservation(clientList: [Cell], duration: 2, breakfast: false)
let Reservation5 = try hotelManager.addReservation(clientList: [Gohan], duration: 1, breakfast: false)


// Verifico errores al añadir reservas duplicadas (por ID o si otro cliente ya está en alguna otra reserva), y que nuevas reservas sean añadidas correctamente.

func testAddReservation() {
    assert(Reservation1.id == 1)
    assert(Reservation1.id != Reservation2.id)
    assert(Reservation3.id != Reservation4.id)
    assert(Reservation4.id != Reservation5.id)
    assert(Reservation3.id == 3)
    
    do {
        let reservationFail1 = try hotelManager.addReservation(clientList: [Bardock], duration: 5, breakfast: false)
    } catch {
        print(ReservationError.repeatedClient)
    }

}

try hotelManager.cancelReservation(reservationIdToRemove: 2)

// Verifico que las reservas se cancelen correctamente y que al cancelar una reserva no existente nos devuelve un error.

func testCancelReservation() {
    assert(hotelManager.reservationList.count == 2)
}

// Me aseguro de que el sistema calcula los precios de forma consistente. Es decir, si hago dos reservas con los mismos parámetros me deberían dar el mismo precio.

func testReservationPrice() {
    assert(Reservation1.price == Reservation2.price)
}

