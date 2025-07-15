module nft:: nft {   //defines a new module named nft

    use sui::url::{Self, Url}; //Imports the Url struct and related functions from the Sui standard library.
     //This allows you to use URLs (e.g., for NFT metadata) in your module.

    use std::string; //Imports the string module, This gives you access to string types and utilities.

    use sui::event; //Let you emit event. E.g., when an NFT is minted out.

    use sui::display;//provides functionality for defining how objects are displayed in wallets, explorers, and other apps.


    /// An example NFT that can be minted by anybody
    public struct NFT has key, store { //defines a struct with the key and store abilities. 
    //key means the struct can be used as a Sui object and will have a unique ID, while store allows the struct to be stored in global storage and transferred.

        id: UID,//is required for all Sui objects and ensures each NFT is unique and trackable on-chain.

        ///Name for the token
        name: string::String, //A string field for the NFT’s name.

        /// Description of the token
        description: string::String, //A string field for the NFT’s description.It provides more details about the nft.


        /// URL for the token
        url: Url, //A URL field for the NFT’s metadata or image. It points to an image or metadata file.
    }

    ///Mint NFT
    public struct Mintnft_event has copy, drop { //defines a public struct with the abilities to "copy"
    // i.e. Instances of this struct can be copied (useful for events)
    // drop: Instances can be dropped (deleted) when no longer needed.
    // It is an event emitted when an nft is minted out.

        // The Object ID of the NFT
        object_id: ID,
        // The creator of the NFT
        creator: address,
        // The name of the NFT
        name: string::String,
    }

    /// Create a new nft
    public entry fun mint( // declares a public entry function means this function can be called directly in a Sui transaction.
        name: vector<u8>,//The name of the NFT, provided as a UTF-8 byte vector.
        description: vector<u8>,// "
        url: vector<u8>,//The URL for the NFT’s metadata or image, as a UTF-8 byte vector
        ctx: &mut TxContext//mutable reference to the transaction context.
        //it is required for creating new objects and accessing the sender’s address
    ) {
        let nft = NFT {
            id: object::new(ctx),//Generates a new unique object ID using the transaction context.
            name: string::utf8(name),
            description: string::utf8(description),
            url: url::new_unsafe_from_bytes(url)
        };
        let sender = tx_context::sender(ctx);//get the sender's address from the tx ctx
        event::emit(Mintnft_event {
            object_id: object::uid_to_inner(&nft.id),
            creator: sender,
            name: nft.name,
        });
        transfer::public_transfer(nft, sender);
    }

    /// Update the `description` of `nft` to `new_description`
    public entry fun update_description(
        nft: &mut NFT,
        new_description: vector<u8>,
    ) {
        nft.description = string::utf8(new_description)
    }

    /// Permanently delete nft
    public entry fun burn(nft: NFT) {
        let NFT { id, name: _, description: _, url: _ } = nft;
        object::delete(id)
    }

    /// Get the NFT's name
    public fun name(nft: &NFT): &string::String {
        &nft.name
    }

    /// Get the NFT's description
    public fun description(nft: &NFT): &string::String {
        &nft.description
    }

    /// Get the NFT's url
    public fun url(nft: &NFT): &Url {
        &nft.url
    }
}
