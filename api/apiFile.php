<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, DELETE,PUT");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

$connect = mysqli_connect("localhost", "root", "", "names");
function getRandomName()
{
    $names = ["John", "Jane", "Alex", "Emily", "Michael", "Sarah", "David", "Emma", "Chris", "Olivia"];
    return $names[array_rand($names)];
}
//get specific name with id or get all
if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    if (isset($_GET['id'])) {
        $people = [];
        $id = $_GET['id'];
        $result = mysqli_query($connect, "select * from people where id = $id");
        if ($result) {
            while ($row = mysqli_fetch_assoc($result)) {
                $people[] = $row;
            }
        }
        echo json_encode($people);
    } else {
        $people = [];
        $result = mysqli_query($connect, "select * from people");
        if ($result) {
            while ($row = mysqli_fetch_assoc($result)) {
                $people[] = $row;
            }
        }

        echo json_encode($people);
    }
}
//add data to database
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $data = json_decode(file_get_contents("php://input"), true);

    if (!empty($data['name']) && !empty($data['age'])) {
        $name = mysqli_real_escape_string($connect, $data['name']);
        $age = intval($data['age']); // Ensure age is a number

        $query = "INSERT INTO people (name, age) VALUES ('$name', $age)";

        if (mysqli_query($connect, $query)) {
            echo json_encode(["message" => "Person added successfully", "id" => mysqli_insert_id($connect)]);
        } else {
            echo json_encode(["error" => "Failed to add person"]);
        }
    } else {
        echo json_encode(["error" => "Name and age are required"]);
    }
}
//delete data from database
if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
    // Get ID from query string (http://192.168.100.21/api/apiFile.php?id=2)
    if (isset($_GET['id']) && is_numeric($_GET['id'])) {
        $id = intval($_GET['id']); // Convert to integer
        $query = "DELETE FROM people WHERE id = $id";

        if (mysqli_query($connect, $query)) {
            echo json_encode(["message" => "Person with ID $id deleted successfully"]);
        } else {
            echo json_encode(["error" => "Failed to delete person"]);
        }
    } else {
        echo json_encode(["error" => "Invalid or missing ID"]);
    }
}
//edit data
if ($_SERVER['REQUEST_METHOD'] === 'PUT') {
    $data = json_decode(file_get_contents("php://input"), true);

    if (!empty($data['id']) && !empty($data['name']) && !empty($data['age'])) {
        $id = intval($data['id']); // Convert to integer
        $name = mysqli_real_escape_string($connect, $data['name']);
        $age = intval($data['age']);

        $query = "UPDATE people SET name='$name', age=$age WHERE id=$id";

        if (mysqli_query($connect, $query)) {
            echo json_encode(["message" => "Person with ID $id updated successfully"]);
        } else {
            echo json_encode(["error" => "Failed to update person"]);
        }
    } else {
        echo json_encode(["error" => "ID, name, and age are required"]);
    }
}
